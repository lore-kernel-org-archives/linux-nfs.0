From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NSFproblem lockd: server  not responding, still trying
Date: Wed, 10 Dec 2008 13:45:50 -0500
Message-ID: <20081210184550.GC31558@fieldses.org>
References: <493F00FB.2060105@aust.edu.ng>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Adesuyan <bobby-ufAfj23ATiXovzDjfJyo/Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186AbYLJSpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 13:45:52 -0500
In-Reply-To: <493F00FB.2060105-ufAfj23ATiXovzDjfJyo/Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2008 at 12:36:27AM +0100, Adesuyan wrote:
> hi guys
>
> am having some issues with nfs the home directories of all the computers  
> in my school is mounted on the fileserver via nfs mount . for quite some  
> times now users have been experiencing issues with their desktop  
> freezing.   i checked the syslogs and i found this  
> http://pastebin.com/m69dde24e
>    a little googling showed there was a kernel 2.6 bug which happens  
> when you  have had with fast server cards and slow client cards when a
>                   2.6.x kernel is used on the server.
>   the fileserver is on a gigabit card
>    while the client are all on 10/100  so i guess am affected
>   i tried apply the fix in this wiki  
> http://wiki.ltsp.org/twiki/bin/view/Ltsp/NFS#NFS_Server_not_responding
>  but am not sure if i got it right .. or if it applies to the case where 
> one mounts the home directory from the fileserver but the system
>  boots up local (not through the network)

It's lockd that's not responding, not nfsd, so I don't think the problem
you're seeing is the one described there.

> someone i met at #linux-nfs suggested i use NFS over TCP on the client

Always good advice, but again probably unrelated.

> i did but it didnt fix the issue am running ubuntu hardy heron on an
> HP  server .

You're talking here about your nfs server?

--b.

> any help would be appreciated.this problem has made life very  
> frustrating for staffs of my school because we use only linux it would  
> be a great relive if you guys can help us resolve it. thanks in advance
