Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:57352 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab0K2VHK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 16:07:10 -0500
Date: Mon, 29 Nov 2010 16:07:08 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>, sfaibish <sfaibish@emc.com>
Subject: Block layout rpm
Message-ID: <20101129210708.GA21682@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have released a developer's snapshot Fedora rpm of nfs-utils for the pnfs
block layout client, at:
http://www.citi.umich.edu/projects/nfsv4/pnfs/block/

Instructions, as always, are on the wiki:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

While this rpm does contain fixes that aren't yet in Steve's Fedora pnfs
rpm, it is really only intended for block layout testing.  If you do try it,
please report results (positive or negative) to me.
