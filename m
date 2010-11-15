Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:57325 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900Ab0KOTPf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:15:35 -0500
Date: Mon, 15 Nov 2010 14:15:33 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>, sfaibish <sfaibish@emc.com>
Subject: fileid changed
Message-ID: <20101115191533.GA31837@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With Benny's pnfs-all-latest kernel of this morning I'm getting this:

NFS: server emc-1 error: fileid changed
fsid 0:14: expected fileid 0x4c1b59f7, got 0x167
NFS: server emc-1 error: fileid changed
fsid 0:14: expected fileid 0x4c891415, got 0x174
NFS: server emc-1 error: fileid changed
fsid 0:14: expected fileid 0x174, got 0x4c891415
NFS: server emc-1 error: fileid changed
fsid 0:14: expected fileid 0x177, got 0x4ce18474
[ followed by many similar lines ]

This happens during test5: read and write of Connectathon basic, pnfs block
layout client, EMC server.  The user process hangs at this point, no oops.
I can provide more details if needed.  This could easily be my screw-up of
course, but I haven't changed anything in my code and I wasn't getting this
with the previous kernel.  So before I dig in I wanted to ask if this rings
a bell for anyone.
