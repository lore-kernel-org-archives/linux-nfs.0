Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34997 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638AbcCURTL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 13:19:11 -0400
Received: by mail-yw0-f174.google.com with SMTP id g127so222871709ywf.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 10:19:10 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:19:06 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christian Robottom Reis <kiko@acm.org>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160321131906.05ec478b@tlielax.poochiereds.net>
In-Reply-To: <20160321143914.GA6397@anthem.async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Mar 2016 11:39:14 -0300
Christian Robottom Reis <kiko@acm.org> wrote:

> Hello there,
> 
>     I run a diskless network where every user NFS mounts pretty much
> everything including /home and /var/mail. It's often the case that a
> misbehaved client will leave a locked file stuck on the server -- today
> it is a file in a user's mail/ directory.
> 
> Is there a way to query what files are being held locked by clients? I'm
> sure the kernel knows, as it is able to enforce the lock, but it isn't
> obvious how to extract that information -- lsof is documented to and
> indeed does not return any information pertaining NFS client locks, and
> I'm not clear whether /proc/locks (on the server side obviously) does or
> not.
> 

/proc/locks will generally show you all of the locks being held
(assuming the filesystem's ->lock routine records the locks). It's not
really possible to match those up with a particular client though.

> A related question is whether it is possible to break a client lock
> without rebooting the server (or restarting the NFS services).
> 
> Does anyone have any insight to share? Thanks,

I assume you're using NFSv3? What happens when the client "misbehaves"?
Are the clients dropping offline or do you have applications that are
just sitting on the lock and not releasing it?

If the clients are just going away without unlocking first, then you
could consider using NFSv4, which has a lease-based locking. If the
client goes away for a while (90s or so), then it'll lose its lock.

Alternately, there is the /proc/fs/nfsd/unlock_ip interface. Supposedly
you can echo an address into there and it'll forcibly drop all of the
locks that that that client holds. I've not used that so YMMV there.
 
-- 
Jeff Layton <jlayton@poochiereds.net>
