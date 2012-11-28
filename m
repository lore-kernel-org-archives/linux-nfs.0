Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:55083 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755290Ab2K1Boy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 20:44:54 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TdWhz-0006c3-3l
	for linux-nfs@vger.kernel.org; Wed, 28 Nov 2012 02:45:03 +0100
Received: from jua06-1-82-242-159-238.fbx.proxad.net ([82.242.159.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2012 02:45:03 +0100
Received: from lists by jua06-1-82-242-159-238.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2012 02:45:03 +0100
To: linux-nfs@vger.kernel.org
From: Andrei <lists@andreicostin.com>
Subject: MIPIO information + MIPIO vs MPIO
Date: Wed, 28 Nov 2012 01:41:48 +0000 (UTC)
Message-ID: <loom.20121128T023931-160@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am looking for more information on MIPIO.

To give a small background, I need to fix/patch a script in a system which I
have no idea of:
 - basically there is a /dev/mipio device driver on a hardware platform
 - it is configured to get an IP address via ifconfig
 - all the hints is that it's an IP-based distributed filesystem, but there is
no docs whatsoever
 - just need to figure out the specs (terminology mess included) and the purpose
of this /dev/mipio type of device so that i fire the patch and move on

I could find plenty of info on similarly spelling (and contextually similar) 
MPIO (MultiPath I/O), which is usually found also in the context of distributed
filesystems/storages, 
SCSI solutions, etc.
(http://pic.dhe.ibm.com/infocenter/aix/v7r1/index.jsp?topic=%2Fcom.ibm.aix.baseadmn%2Fdoc%2Fbaseadmndita%2Fdevmpio.htm)

I would kindly request if someone could really help point me into the right
direction:
 - is _generally_ MIPIO same as MPIO or not?
 - can someone provide in private some links/docs on MIPIO?
 - can someone provide his/her prior experience with such /dev/mipio
programming/sysadmining?

PS: the only MIPIO references I could find is
"http://permalink.gmane.org/gmane.linux.nfs/28617", 
this is why I took the chances of writing to linux.nfs :) - apologies if it's
the wrong place to ask, 
appreciate hints for the right place to ask.

Thanks.

Cheers,
Andrei

