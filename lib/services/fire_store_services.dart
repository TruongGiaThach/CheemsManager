import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:to_do_list/models/meta_user_model.dart';

import '../models/comment_model.dart';
import '/constants/app_colors.dart';
import '/models/project_model.dart';
import '/models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore;
  FirestoreService(this._firebaseFirestore);

  Stream<List<ProjectModel>> projectStream(String uid) {
    return _firebaseFirestore
        .collection('project')
        .where('id_author', isEqualTo: uid)
        .snapshots()
        .map(
          (list) => list.docs.map((doc) {
            return ProjectModel.fromFirestore(doc);
          }).toList(),
        );
  }

  Stream<List<TaskModel>> taskStream() {
    return _firebaseFirestore.collection('task').snapshots().map(
          (list) => list.docs.map((doc) {
            return TaskModel.fromFirestore(doc);
          }).toList(),
        );
  }

  Stream<List<CommentModel>> commentStream(String taskId) {
    return _firebaseFirestore
        .collection('task')
        .doc(taskId)
        .collection('comment')
        .snapshots()
        .map(
          (list) => list.docs.map((doc) {
            return CommentModel.fromFirestore(doc);
          }).toList(),
        );
  }

  Stream<TaskModel> taskStreamById(String id) {
    return _firebaseFirestore
        .collection('task')
        .doc(id)
        .snapshots()
        .map((doc) => TaskModel.fromFirestore(doc));
  }

  Stream<MetaUserModel> userStreamById(String id) {
    return _firebaseFirestore
        .collection('user')
        .doc(id)
        .snapshots()
        .map((doc) => MetaUserModel.fromFirestore(doc));
  }

  Future<MetaUserModel> getUserById(String id) {
    return _firebaseFirestore
        .collection('user')
        .doc(id)
        .get()
        .then((doc) => MetaUserModel.fromFirestore(doc));
  }

  Stream<ProjectModel> projectStreamById(String id) {
    return _firebaseFirestore
        .collection('project')
        .doc(id)
        .snapshots()
        .map((doc) => ProjectModel.fromFirestore(doc));
  }

  Stream<List<MetaUserModel>> userStream(String email) {
    return _firebaseFirestore
        .collection('user')
        .where('email', isNotEqualTo: email)
        .snapshots()
        .map(
          (list) => list.docs.map((doc) {
            return MetaUserModel.fromFirestore(doc);
          }).toList(),
        );
  }

  DocumentReference getDoc(String collectionPath, String id) {
    return _firebaseFirestore.collection(collectionPath).doc(id);
  }

  Future<MetaUserModel> getMetaUserByIDoc(DocumentReference doc) {
    return doc.get().then((value) => MetaUserModel.fromFirestore(value));
  }

  Future<ProjectModel> getProject(DocumentReference doc) {
    return doc.get().then((value) => ProjectModel.fromFirestore(value));
  }

  Future<bool> deleteQuickNote(String uid, String id) async {
    await _firebaseFirestore
        .collection('user')
        .doc(uid)
        .collection('quick_note')
        .doc(id)
        .delete()
        .then((value) {
      servicesResultPrint("Quick note Deleted");
      return true;
    }).catchError((error) {
      servicesResultPrint("Failed to delete quick note: $error");
      return false;
    });
    return false;
  }

  void addProject(ProjectModel project) {
    _firebaseFirestore.collection('project').doc().set(project.toFirestore());
  }

  Future<bool> addTaskProject(ProjectModel projectModel, String taskID) async {
    List<String> list = projectModel.listTask;
    list.add(taskID);

    await _firebaseFirestore.collection('project').doc(projectModel.id).update({
      "list_task": list,
    }).then((value) {
      servicesResultPrint('Added task to project');
      return true;
    }).catchError((error) {
      servicesResultPrint('Add task to project failed: $error');
      return false;
    });
    return true;
  }

  Future<void> completedTaskById(String id) async {
    await _firebaseFirestore
        .collection('task')
        .doc(id)
        .update({"completed": true}).then((value) {
      servicesResultPrint('Completed Task');
    }).catchError((error) {
      servicesResultPrint('Completed Task failed: $error');
    });
  }

  Future<void> updateDescriptionUrlTaskById(String id, String url) async {
    await _firebaseFirestore
        .collection('task')
        .doc(id)
        .update({"des_url": url}).then((value) {
      servicesResultPrint('Update url successful');
    }).catchError((error) {
      servicesResultPrint('Update url failed: $error');
    });
  }

  Future<void> updateDescriptionUrlCommentById(
      String taskId, String commentId, String url) async {
    await _firebaseFirestore
        .collection('task')
        .doc(taskId)
        .collection('comment')
        .doc(commentId)
        .update({"url": url}).then((value) {
      servicesResultPrint('Update url successful');
    }).catchError((error) {
      servicesResultPrint('Update url failed: $error');
    });
  }

  Future<void> createUserData(
      String uid, String displayName, String email) async {
    await _firebaseFirestore.collection('user').doc(uid).set({
      'display_name': displayName,
      'email': email,
    }).then((value) {
      servicesResultPrint('Create user data successful', isToast: false);
    });
  }

  Future<void> updateUserAvatar(String uid, String url) async {
    await _firebaseFirestore.collection('user').doc(uid).update({
      'url': url,
    }).then((value) {
      servicesResultPrint('Update avatar successful', isToast: false);
    });
  }

  Future<String> addTask(TaskModel task) async {
    DocumentReference doc = _firebaseFirestore.collection('task').doc();
    await doc.set(task.toFirestore()).then((onValue) {
      servicesResultPrint('Added task');
    }).catchError((error) {
      servicesResultPrint('Add task failed: $error');
    });
    return doc.id;
  }

  Future<String> addComment(CommentModel comment, String taskId) async {
    DocumentReference doc = _firebaseFirestore
        .collection('task')
        .doc(taskId)
        .collection('comment')
        .doc();
    await doc.set(comment.toFirestore()).then((onValue) {
      servicesResultPrint('Added comment');
    }).catchError((error) {
      servicesResultPrint('Add comment failed: $error');
    });
    return doc.id;
  }

  Future<bool> deleteTask(String id) async {
    await _firebaseFirestore.collection('task').doc(id).delete().then((value) {
      servicesResultPrint("Task Deleted");
      return true;
    }).catchError((error) {
      servicesResultPrint("Failed to delete task: $error");
      return false;
    });
    return false;
  }

  Future<bool> updateTask(TaskModel task) async {
    await _firebaseFirestore
        .collection('task')
        .doc(task.id)
        .set(task.toFirestore())
        .then((value) {
      servicesResultPrint("Task updated");
      return true;
    }).catchError((onError) {
      servicesResultPrint("Failed to update task: $onError");
      return false;
    });
    return false;
  }

  void servicesResultPrint(String result, {bool isToast = true}) async {
    print("FirebaseStore services result: $result");

    if (isToast)
      await Fluttertoast.showToast(
        msg: result,
        timeInSecForIosWeb: 2,
        backgroundColor: AppColors.kWhiteBackground,
        textColor: AppColors.kText,
      );
  }
}
