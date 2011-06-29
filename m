Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:37676 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab1F2HVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 03:21:52 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5T7FWAL009462
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 17:15:32 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5T7KNIQ979122
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 17:20:23 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5T7LfJp011832
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 17:21:42 +1000
Message-ID: <4E0AD278.3000503@linux.vnet.ibm.com>
Date: Wed, 29 Jun 2011 12:51:28 +0530
From: faizan husain <faizanh@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
CC: Frank S Filz <ffilz@us.ibm.com>, jvrao@linux.vnet.ibm.com
Subject: [PATCH] nfs4-acl-tools : nfs4_setfacl' failed with unexpected messages
 if the format of the input file is incorrect.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On RHEL5.5 and above releases,
read ACL entries to set from file leads to a segmentation fault on pp64,
more over the same problem does not show up for x86_64 architecture.

here is what i tried.
mounted a file system over nfs4.

#rpm -qa | grep nfs4
nfs4-acl-tools-0.3.3-5.el6.ppc64

'nfs4_setfacl' failed with unexpected message:
#nfs4_setfacl -S file4 file1
*** glibc detected *** nfs4_setfacl: double free or corruption (out):
0x08007760 ***
expected out should be like
Scanning ACE string 'abcd' failed.
Failed while inserting ACE(s).


 From b8333732964780394518be74ab0b7c61a7e4be4f Mon Sep 17 00:00:00 2001
From: faizan <faizan.husain@xxxxxxx>
Date: Tue, 28 Jun 2011 16:06:47 +0530
Subject: [PATCH][BUILD]] FIX - 'nfs4_setfacl' failed with unexpected 
messages iff
the format of the input file is incorrect.


Signed-off-by: faizan <faizan.husain@xxxxxxxx>
---
  libnfs4acl/nfs4_ace_from_string.c |    1 -
  1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c 
b/libnfs4acl/nfs4_ace_from_string.c
index 9d877fb..1cc220e 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -125,7 +125,6 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])

         return 0;
  out_free:
-       free_fields(fields);
         return -ENOMEM;
  }

--
1.7.1

Regards
Faizan

