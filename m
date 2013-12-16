Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:60351 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640Ab3LPSVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Dec 2013 13:21:49 -0500
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id A7380258091
	for <linux-nfs@vger.kernel.org>; Mon, 16 Dec 2013 19:16:00 +0100 (CET)
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: nfs-utils-1.2.9 does not play well with linux 3.10.x
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se>
Date: Mon, 16 Dec 2013 19:16:00 +0100
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.nfsd insists on adding "-4.2" when writing /proc/fs/nfsd/versions :
  rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
Which causes Linux to return an EIVAL error as 3.10 has no support for 4.2 
and
does not accept any reference to 4.2

It seems reasonable to me that Linux should accpect -4.2 as a noop and 
continue
processing the rest of the options but I am just guessing.
Anyhow, just to test I applied this commit to my 3.10.24 kernel:
   
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=4bdc33ed5bd9fbaa243bda6fdccb22674aed6305
and now it accepts the "-4.2" but I have no idea if this messes up 
something else.
Ideas?

 Jocke
