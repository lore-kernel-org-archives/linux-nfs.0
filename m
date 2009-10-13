From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Tue, 13 Oct 2009 13:51:33 -0400
Message-ID: <1255456293.3711.103.camel@heimdal.trondhjem.org>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	 <20091009121602.5ec86dfb@tlielax.poochiereds.net>
	 <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	 <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	 <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	 <20091013114441.2882c8b9@tlielax.poochiereds.net>
	 <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
	 <1255452985.3711.85.camel@heimdal.trondhjem.org>
	 <20091013132701.72927b4d@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kevin Coffman <kwc@citi.umich.edu>, raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56022 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760478AbZJMRwR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 13:52:17 -0400
In-Reply-To: <20091013132701.72927b4d-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-10-13 at 13:27 -0400, Jeff Layton wrote:
> Correct...and gssd actually does check the validity of the cache. If
> TGT has expired or it's not valid for some other reason, then it skips
> it and moves on.
> 
> The problem comes when you have more than one valid credcache. In that
> case it picks the one with the latest mtime. It seems that it should
> instead pick the one with the latest TGT expiration time.

So why do you think that is a problem? The result should be that
rpc.gssd always ends up with a valid credential as long as there is at
least one with a valid TGT.
IOW: Who cares if the GSS session isn't going to last as long, as long
as the RPC client can always instantiate a new one.

Trond

