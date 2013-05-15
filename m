Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:57598 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab3EOUqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 16:46:22 -0400
Received: from mailout-de.gmx.net ([10.1.76.31]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0LyPqS-1UPoHD1hQ6-015udi for
 <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 22:46:21 +0200
Message-ID: <5193F41C.1070601@gmx.de>
Date: Wed, 15 May 2013 22:46:20 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: see comments nfs_fs.h:seqid_mutating_error()
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mentioned 2x in fs/nfs/nfs4state.c but I didn't found the comments.

back ground: fuzzying a 32 bit user mode linux guest brought up (rather rarely, but nevertheless) :

NFS: v4 server returned a bad sequence-id error on an unconfirmed sequence 48f401f0!
-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
