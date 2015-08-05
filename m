Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tamar.safe-mail.net ([212.29.227.229]:35656 "EHLO
	tamar.safe-mail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbHEOGt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:06:49 -0400
Received: by tamar.safe-mail.net with Safe-mail (Exim 4.66)
	(envelope-from <jhopper@Safe-mail.net>)
	id 1ZMwdy-0007Ty-S2
	for linux-nfs@vger.kernel.org; Wed, 05 Aug 2015 07:13:58 -0400
Subject: extremely slow v4 performance on gigabit link
Date: Wed, 5 Aug 2015 07:13:58 -0400
From: jhopper@Safe-mail.net
To: linux-nfs@vger.kernel.org
Message-Id: <N1B-heRnt8zOCE@Safe-mail.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a very slow (less than 1MB/s) performance with nfsv4 TCP, rsize/wsize have no effect, server is a kernel 3.19 x86 100hz no preempt exporting async nfsv4 TCP on nfs-utils 1.2.7, client is a kernel 4.1.3 x64 1000hz full preempt with nfs-utils 1.3.2 , physical link is 1 gigabit full duplex, I mounted a few cifs shares to check, the cifs shares are working at 30 MB/s and higher

is it possible that preempt has an effect on NFS performance ? does timeslice have effect on performance ?
