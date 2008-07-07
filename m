From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Doc for adding new NFS export option
Date: Mon, 07 Jul 2008 13:39:32 +1000
Message-ID: <48718FF4.4030200@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:50007 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754103AbYGGD7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Jul 2008 23:59:35 -0400
Received: From
	[203.143.160.170] ([203.143.160.170] == chaos.ken.nicta.com.au) (auth-user shehjart) (cse-authentic-sender shehjart)
	(for <linux-nfs@vger.kernel.org>) By tone With Smtp ;
	Mon, 7 Jul 2008 13:53:28 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

Is there a document that enumerates which files and functions I need 
to add stuff to, for adding a new server-side export option?

I've tried adding it to some of the functions in the exportfs related 
code in nfs-utils and also in the kernel's export related headers but 
I dont think that is all there is to it.

I ask this because without my new option, I am able to mount the 
export correctly but with it, the mount command fails with the 
following message:

mount.nfs: 192.168.10.5:/data/nfstest failed, reason given by server: 
Permission denied

I'd appreciate any help.

Thanks
Shehjar
