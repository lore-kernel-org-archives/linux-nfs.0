Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:49700 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280Ab0KJSBq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 13:01:46 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id oAAI1igo028714
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 23:31:44 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAAI1eYS1630334
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 23:31:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAAI1d7Y024185
	for <linux-nfs@vger.kernel.org>; Thu, 11 Nov 2010 05:01:39 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: NFSv4 ACL set and inode attribute cache
Date: Wed, 10 Nov 2010 23:31:31 +0530
Message-ID: <m3hbfpvz0k.fsf@linux.vnet.ibm.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi,

I guess we are not marking the inode attribute as invalid when we set
the ACL value. For ex:

/d# mkdir sub3
/d# ls -dl sub3
drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
/d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
/d# ls -dl sub3
drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
/d# 


On the server i have the mode bits as
/d# ls -dl sub3
drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
/d# 


-aneesh
