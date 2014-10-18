Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:63994 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbaJRV7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Oct 2014 17:59:07 -0400
Received: from [192.168.178.21] ([80.171.109.239]) by mail.gmx.com (mrgmx003)
 with ESMTPSA (Nemesis) id 0LtIdP-1Y7haN0zOd-012qbD for
 <linux-nfs@vger.kernel.org>; Sat, 18 Oct 2014 23:59:04 +0200
Message-ID: <5442E2A4.9030006@gmx.de>
Date: Sat, 18 Oct 2014 23:59:00 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: fuzz testing gave today : "kernel: NFS: nfs4_reclaim_open_state:
 unhandled error -13"
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

happens within a 32 bit user mode linux guest running latest git tree v3.17-9981-g929254d
It occurred few times about half an hour after the test case was started.

Well, it is very early in the current release cycle, so just asking, if this is already known / worth to investigate ?
-- 
Toralf
pgp key: 0076 E94E

