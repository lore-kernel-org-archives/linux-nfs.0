Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57297 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab1GZOnt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 10:43:49 -0400
Received: by gwaa18 with SMTP id a18so284191gwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 07:43:48 -0700 (PDT)
Message-ID: <4E2ED2A0.4030401@marcanoonline.com>
Date: Tue, 26 Jul 2011 10:13:44 -0430
From: Robert Marcano <robert@marcanoonline.com>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 / POSIX ACL mapping bug?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, This question is probably too simple for this nfs developer list, 
but I am intrigued to know if this is a bug or not, I do not find any 
other reference to anyone with this problem

Ineed some help clarifying this issue in order to know if this is a bug 
or limits of the NFSv4 / POSIX ACL mapping before reporting it

Creating a directory on the server with the following POSIX ACLs, rwx 
for the group "sharedgroup" and same defaults:

############################################################
# file: directory
# owner: root
# group: root
user::rwx
group::r-x
group:sharedgroup:rwx
mask::rwx
other::---
default:user::rwx
default:group::r-x
default:group:sharedgroup:rwx
default:mask::rwx
default:other::---
############################################################

Creating files with the same user with umask 022 on the server an on the 
NFS client, the files do not get the same POSIX ACL mask:

############################################################
# file: client
# owner: test
# group: testgroup
user::rw-
group::r-x                   #effective:r--
group:sharedgroup:rwx        #effective:r--
mask::r--
other::r--

# file: server
# owner: test
# group: testgroup
user::rw-
group::r-x                   #effective:r--
group:sharedgroup:rwx        #effective:rw-
mask::rw-
other::r--
############################################################

Is this normal or a bug?, My interpretation is that even that the 
mapping of the ACLs is not 100% perfect this simple example should not 
be a problem. Is it impossible using NFS to create a shared directory 
for a group of users?

Thanks in advance
