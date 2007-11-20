From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: Files getting out of sync between client/server
Date: Tue, 20 Nov 2007 16:25:48 -0500 (EST)
Message-ID: <Pine.BSO.4.64.0711201620090.28050@citi.umich.edu>
References: <d29a314c0711201313u4e986db3j27b3da95df2bd718@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Stefanovich <sklopp@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:1992 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758514AbXKTVvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Nov 2007 16:51:48 -0500
In-Reply-To: <d29a314c0711201313u4e986db3j27b3da95df2bd718-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 Nov 2007, Stefanovich wrote:

> Hi,
> 
> I have a problem that when uploading files to our NFS server. The
> problem occurs when we overwrite a file using ftp. What happens is
> that on the server the file is uploaded and updated correctly, however
> on our nfs clients the file itself doesn't update, it actually retains
> the information from the previous version of the file. I have tried to
> remount the clients when this occurs but that doesn't fix the problem.
> So far the only way I have found to correct this issue is to
> physically reboot the client machines. Just wondering if anyone knows
> why this might be happening, and any idea on a fix or what I am doing
> wrong?

	the client usually caches data for about 30 seconds, IIRC, so one 
would expect the potential for some sort of window, but unmounting and 
remounting should invalidate all of the client's caches.  what happens if 
the client waits for "a while" -- can you see the data then?  and what 
happens if the client touches the file and then rereads it, maybe (lame, i 
know)?  but, regardless, i don't understand the unmount/remount thing at 
all.

	what kernel version(s) are you using?

	d
	.
