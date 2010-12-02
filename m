Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:49721 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab0LBLJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 06:09:24 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB2B4K34012777
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 22:04:20 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2B9MfS1548408
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 22:09:22 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2B9MKr002474
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 22:09:22 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Umask and ACL on NFS
Date: Thu, 02 Dec 2010 16:39:15 +0530
Message-ID: <m3tyiw4ejo.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi,

POSIX ACL and Richacl want to apply umask on file creation only when we don't have any
inheritable ACEs on the parent directory. Currently with nfsv4 code we do
check for POSIX ACL in nfs_atomic_lookup, but i don't find where we set
the MS_POSIXACL bit for the nfsv4 code.

Even if we try to do something like below

   if (nfs4_server_supports_acls(..))
      sb->s_flags |= MS_POSIXACL;

I guess we could get it wrong. The above implies we may end up not
applying umask for a server supporting ACL even if the parent 
directory don't have inheritable ACEs.

I found a proposal to add umask attribute at
http://www.ietf.org/mail-archive/web/nfsv4/current/msg07159.html
http://www.ietf.org/proceedings/74/slides/nfsv4-3.pdf
                                
So what is the expected behaviour for NFS. Should we always apply
umask (which is what it currently does) irrespective of whether
parent directory have inheritable ACEs or not ?

-aneesh
