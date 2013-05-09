Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947Ab3EIWTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 18:19:48 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r49MJm9S015417
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 9 May 2013 18:19:48 -0400
Received: from smallhat.bos.devel.redhat.com ([10.16.60.65])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r49MJmIF031389
	for <linux-nfs@vger.kernel.org>; Thu, 9 May 2013 18:19:48 -0400
Message-ID: <518C2104.7060107@RedHat.com>
Date: Thu, 09 May 2013 18:19:48 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: RPC: AUTH_GSS upcall timed out.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

commit 4edaa308888b4bd629fa025cc6d5b2bf1a2a51db
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sat Mar 16 15:56:20 2013 -0400

    NFS: Use "krb5i" to establish NFSv4 state whenever possible

Introduced a hard code call to nfs_create_rpc_client(RPC_AUTH_GSS_KRB5I)
in nfs4_init_client() which means if rpc.gssd is not running the mount 
hangs for a bit logs the "RPC: AUTH_GSS upcall timed out" and then tries 
nfs_create_rpc_client(RPC_AUTH_NULL) allowing the mount to succeed.

Is this a known "feature"? 

steved.
 
