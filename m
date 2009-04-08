From: Loris Boillet <lb-ROyWabVH00V/SzgSGea1oA@public.gmane.org>
Subject: rpc.mountd and hotplug: very high CPU usage
Date: Wed, 8 Apr 2009 10:35:00 +0200
Message-ID: <200904081035.00351.lb@locatel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from majestix.2m.dk ([194.239.1.200]:47550 "EHLO majestix.2m.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121AbZDHIlK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2009 04:41:10 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by majestix.2m.dk (Postfix) with ESMTP id AA7BCC10068
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2009 10:35:00 +0200 (CEST)
Received: from majestix.2m.dk ([127.0.0.1])
	by localhost (majestix.2m.dk [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yY-RN8JB-xOJ for <linux-nfs@vger.kernel.org>;
	Wed,  8 Apr 2009 10:35:00 +0200 (CEST)
Received: from lblt.local (miraculix.2m.dk [194.239.1.62])
	by majestix.2m.dk (Postfix) with ESMTP id 95003C10025
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2009 10:35:00 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am using hotplug to handle automounting of USB storage devices on an 
embedded box (superH 4 CPU). The issue is that when I restart the nfs related 
processes from the hotplug context, rpc.mountd then will eat all of the CPU 
ressources. The only way I found to stop this is to restart it outside from 
the hotplug context. I have no idea why it is doing this - I could only check 
that it's not bash's environment related. The box does not support gdb and I 
did not investigate on a more classic machine to see if this bug is 
architecture independant or not. But as I couldn't see this problem reported 
anywhere I thought I shoud report it somewhere !

Cheers,

Loris
