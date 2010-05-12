Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:39467 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757158Ab0ELWWT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 18:22:19 -0400
Received: from ns.sks3.muni.cz (sks.bb10.muni.cz [147.251.242.226] (may be forged))
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id o4CMEPRg017648
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 00:14:26 +0200
Received: from [147.251.209.121] (jk.sks3.muni.cz [147.251.209.121])
	by ns.sks3.muni.cz (Postfix) with ESMTP id 7CEE69E201
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 00:14:20 +0200 (CEST)
Message-ID: <4BEB283C.1020102@atlas.cz>
Date: Thu, 13 May 2010 00:14:20 +0200
From: Jiri Kortus <sumix@atlas.cz>
To: linux-nfs@vger.kernel.org
Subject: pNFS-related questions
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'd like to ask two questions that are related to pNFS, I hope it's not 
a problem that I put them in one post even though they aren't related 
one to the other.

1. How to configure a pNFS+exofs setup with multiple OSD targets? I was 
able to use a setup with one OSD target, one OSD initiator+pNFS metadata 
server and one client with the help of pNFS mailing list and the 
instructions from here 
http://mailman.open-osd.org/pipermail/osd-dev/2009-July/001033.html 
which seems to be quite clear to me. But I've been thinking about how a 
setup with more OSDs would look like? (I mean mainly the metadata 
server). I suppose that I would configure more OSDs in the same way as I 
did with one. Then how about the pNFS MDS setup? I've been wondering if 
I could do it this way:
- login to the targets, then mount /dev/osdX devices for example in 
/exofs/osdX
- set up the /etc/exports file in this way:
/exofs    *(....,fsid=0,pnfs)
/exofs/osd1    *(....)
/exofs/osd2    *(....)
...
/exofs/osdX    *(....)

- then reload the exports by running "exportfs -r"
- and finally I would login to the OSDs on the client, load 
objlayoutdriver and mount the export from MDS with the "minorversion=1" 
option.
Could the content of /etc/exports file look like that? Or is it 
fundamentally wrong? I'd be glad for any advice. I can't test it right 
now but I have to know how to do it to describe it in my bachelor's thesis.


2. I'd like to know how well the IPv6 support in pNFS works - what 
works, what doesn't, if there are any problems to solve etc., just 
anything worth to know concerning the IPv6 support.

Thank you very much in advance.

Best regards,

Jiri Kortus
