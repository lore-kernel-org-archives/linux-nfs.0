From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Wed, 16 Apr 2008 07:44:04 -0400
Message-ID: <20080416074404.25b59adb@barsoom.rdu.redhat.com>
References: <200804161117.24734.hensema@hostingxs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Erik Hensema / HostingXS Internet Services <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46874 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757896AbYDPLom (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 07:44:42 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jm648-0005MV-Ay
	for linux-nfs@vger.kernel.org; Wed, 16 Apr 2008 21:44:40 +1000
In-Reply-To: <200804161117.24734.hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Apr 2008 11:17:24 +0200
Erik Hensema / HostingXS Internet Services <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org> wrote:

> Hi all,
> 
> Sometimes a file lock gets stuck. Is there any way on either server or 
> client to obtain a list of locks? Or a list of processes/clients 
> locking a particular file?

$ cat /proc/locks

The PID field can be a little misleading there though. On the server,
it'll generally show the pid of knfsd, and on the client you'll see
the pid of the processes actually doing the locking. As far as I know,
info about which clients have blocked locks isn't exposed.


> And the million dollar question: is it possible to forcefully remove a 
> lock?
> 

Hmm...with NFSv2/3, yes. You can send a SIGKILL to lockd to make it drop
all of its locks. You'll need to couple that with a statd SM_NOTIFY
event to make everyone recover their locks too...

> I'm using NFSv4 on Linux 2.6.18 (server and client).
> 

I don't think the same sort of trick works for NFSv4. I suppose you
could probably shut down all the nfsd's on the server and bring
them back up again. I've never tested that though...

> Met vriendelijke groet,
> 
> 
> Erik Hensema
> -- 
> HostingXS
> eXcellent Service
> 
> Telefoon: 024 - 324 91 77
> E-mail:   hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org
> Website:  http://www.hostingxs.nl/
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> Don't miss this year's exciting event. There's still time to save $100. 
> Use priority code J8TL2D2. 
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

