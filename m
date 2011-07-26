From: Robert Marcano <robert-3g6LKK052cRzu6KWmfFNGwC/G2K4zDHf@public.gmane.org>
Subject: NFSv4 / POSIX ACL mapping bug?
Date: Tue, 26 Jul 2011 12:05:53 -0430
Message-ID: <4E2EECE9.3080500@marcanoonline.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44251 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551Ab1GZQf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 12:35:58 -0400
Received: by yxi11 with SMTP id 11so370624yxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 09:35:57 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
