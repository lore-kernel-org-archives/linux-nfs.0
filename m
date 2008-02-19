From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Tue, 19 Feb 2008 18:18:25 -0500
Message-ID: <1203463105.21343.20.camel@heimdal.trondhjem.org>
References: <1203449166.8156.85.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37611 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbYBSXTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 18:19:03 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1JNIhVj021567
	for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2008 15:19:03 -0800 (PST)
In-Reply-To: <1203449166.8156.85.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How about moving the offending mntput calls off rpciod altogether? That
way we can avoid both the deadlock with rpc_shutdown_client() and the
deadlock with nfs_put_super().
The other advantage of doing this is that we move all those deadlocky
little malloc() calls from the NFSv4 open(), close(), lock(), and
locku() out of rpciod too. Ditto for the delegation return stuff that
may result from the dput() calls...

The way I'm attempting to do this, is to add something like the
following patch series (which has been compile tested, but not
run-tested quite yet). It basically creates an 'nfsiod' workqueue, and
allows the NFS read/write/... code to specify that the
tk_ops->rpc_release() callback should be run on that particular
workqueue. It then moves all the mntput()/dput() stuff into the
rpc_release() call...

Cheers
  Trond
