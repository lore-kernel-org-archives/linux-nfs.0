From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd and hotplug: very high CPU usage
Date: Sun, 12 Apr 2009 13:19:49 -0400
Message-ID: <20090412171949.GC14592@fieldses.org>
References: <200904081035.00351.lb@locatel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Loris Boillet <lb-ROyWabVH00V/SzgSGea1oA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35987 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbZDLRTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Apr 2009 13:19:50 -0400
In-Reply-To: <200904081035.00351.lb-ROyWabVH00V/SzgSGea1oA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2009 at 10:35:00AM +0200, Loris Boillet wrote:
> I am using hotplug to handle automounting of USB storage devices on an 
> embedded box (superH 4 CPU). The issue is that when I restart the nfs related 
> processes from the hotplug context, rpc.mountd then will eat all of the CPU 
> ressources. The only way I found to stop this is to restart it outside from 
> the hotplug context. I have no idea why it is doing this - I could only check 
> that it's not bash's environment related. The box does not support gdb and I 
> did not investigate on a more classic machine to see if this bug is 
> architecture independant or not. But as I couldn't see this problem reported 
> anywhere I thought I shoud report it somewhere !

I haven't seen that before.  Next time it happens an strace or something
might be useful....

--b.
