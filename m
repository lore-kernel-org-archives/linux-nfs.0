Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47384 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab1ASUs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 15:48:26 -0500
Date: Wed, 19 Jan 2011 15:48:20 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: fileid changed
Message-ID: <20110119204820.GA8471@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm getting fresh reports of "fileid changed" with Benny's latest
pnfs-all-latest.  This is x86_64 4.1 non-pnfs client against EMC Celerra
server.  I'm getting a tcpdump now.  The kernel does have the
nfs_same_file() fix that Trond sent in November.

NFS: server 10.244.76.184 error: fileid changed
fsid 0:15: expected fileid 0x19, got 0x4d0000fb
NFS: server 10.244.76.184 error: fileid changed
fsid 0:15: expected fileid 0x1b, got 0x4d00047c
NFS: server 10.244.76.184 error: fileid changed
fsid 0:15: expected fileid 0x1a, got 0x4d00047c
NFS: server 10.244.76.184 error: fileid changed
fsid 0:15: expected fileid 0x1c, got 0x4d00047f
NFS: server 10.244.76.184 error: fileid changed
fsid 0:15: expected fileid 0x1d, got 0x4d000481
