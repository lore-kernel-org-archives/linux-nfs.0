Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25330 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbbIOPw3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 11:52:29 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t8FFqSnR032443
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 15:52:29 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t8FFqSM4022564
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 15:52:28 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.13.8/8.13.8) with ESMTP id t8FFqRjl009823
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 15:52:27 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv4 security negotiation issue
Message-Id: <7A550B5E-9EAB-4431-BBBA-1C77EE86539F@oracle.com>
Date: Tue, 15 Sep 2015 11:52:25 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

We've found an unexpected behavior with mount security
negotiation in the current Linux NFS client.

Given two real shares on an NFS server: one is a sys-only
share, and the other is a krb5-only share. When we try to
mount the sys-only share without specifying a sec= option,
it fails. Specifying sec=sys is successful.

What is seen on the wire:

1. The client attempts to access the pseudofs, and negotiates
krb5

2. The client walks down the pseudofs namespace to the
sys-only share

3. The client attempts to access the sys-only share with krb5
and gets WRONGSEC

4. The client negotiates sys, and continues setting up the
mount

5. nfs_fs_mount_common() invokes nfs_get_root(), but it
uses the pseudofs superblock, so it does a GETATTR on the
share's root directory with krb5, and that fails

At this point the client gives up, and the mount attempt
fails.

We could alter the server to allow a GETATTR with the
same flavor as the underlying directory. But seems like
the problem is on the client: it should use the negotiated
flavor that is appropriate to the share, not the flavor
appropriate for the pseudofs.

Any thoughts?


--
Chuck Lever



