Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:41634 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab1ALS6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 13:58:45 -0500
Date: Wed, 12 Jan 2011 13:58:43 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: state manager failed on NFSv4 server
Message-ID: <20110112185843.GA14207@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A kernel built from Benny's pnfs-all-latest can no longer mount the EMC
server because nfs4_state_manager() fails.  I suspect it doesn't like
something about the EXCHANGE_ID reply.  This worked before Benny's last
update (late Dec?), and I can bisect if necessary, but wondered if someone
here can take a look and see if there is something obviously wrong.

I put a dump of the call and reply here:
http://www.citi.umich.edu/projects/nfsv4/pnfs/block/emc-ng-state-mgr

I can of course provide more info if that would help.
