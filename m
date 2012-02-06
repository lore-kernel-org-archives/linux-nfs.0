Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:24059 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab2BFTLm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 14:11:42 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Possible fixes for 2.6.32 stable
Date: Mon, 6 Feb 2012 14:11:37 -0500
Message-Id: <8FB4CAA9-65A1-498F-BA0B-96AA520EBBA2@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Mime-Version: 1.0 (Apple Message framework v1257)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Oracle's UEK kernel is within a few dozen commits of 2.6.32 stable.  We recently discovered two critical problems with the NFS client in UEK that have upstream fixes that can be back ported.  I'm notifying you as a courtesy because these problems were reproduced in 2.6.32-stable, and the fixes are simple back ports you may wish to apply.


The first issue: The 2.6.32 NFS client fails to perform NFSv4 state recovery after a server reboot if an NFS server returns NFS4ERR_NO_GRACE, and then blocks state recovery because its grace period has not expired.  Because the client fails to perform state recovery, it continues to use stale NFSv4 state tokens, which causes, among other symptoms, an infinite loop with the server.  The fixes for this are:

>From 2.6.33: e345e88a, 4f7cdf18, c8b7ae3d, a9ed2e25

>From 2.6.36: b0ed9dbc

These cleanly apply in that order to 2.6.32.  With these commits applied, our UEK NFS clients are able to perform NFSv4 state recovery correctly when an NFS server returns NFS4ERR_NO_GRACE.


The second issue: After a RPC over TCP connection is dropped, the 2.6.32 RPC client reconnects then immediately drops a new TCP connection, in a loop.  The client's NFS mount point becomes unusable.  The fixes for this are:

>From 2.6.34: 5fe46e9d

>From 2.6.36: 669502ff

These apply cleanly in this order to 2.6.32.  With these commits applied, our UEK NFS clients can reconnect on the first attempt to an NFS server after a TCP connection drop.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




