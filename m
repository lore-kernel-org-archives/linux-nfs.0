Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550Ab3I3OT5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 10:19:57 -0400
Date: Mon, 30 Sep 2013 10:00:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Michael Gliwinski <Michael.Gliwinski@henderson-group.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: gss context cache
Message-ID: <20130930100000.70578c80@tlielax.poochiereds.net>
In-Reply-To: <1702585.AG7n1MCr0K@hgis96>
References: <1702585.AG7n1MCr0K@hgis96>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Sep 2013 13:06:47 +0100
Michael Gliwinski <Michael.Gliwinski@henderson-group.com> wrote:

> Hi all,
> 
> On RHEL6 nfs-utils-1.2.3-36
> 
> man rpc.gssd says it -t wasn't specified then kernel gss contexts will be 
> cached for the lifettime of the Kerberos service ticket used in its creation.  
> Is there a way to see the contexts + service tickets in that cache?
> 

No, AFAIK.

> Also, is there any way short of rebooting the client to evict one entry from 
> that cache, or even clear the cache entirely?
> 

There is a gss_destroy_creds script which ships as part of nfs-utils.
That should basically do what you need, but it's not well-documented so
you'll have to play with it some...

> (looking for this as I had situations where access was denied by the NFS 
> server and I could see the principal was getting mapped to nfsnobody, etc. and 
> was suspecting the account was changed on the KDC and the old context/ticket 
> may have been causing problems)
> 


-- 
Jeff Layton <jlayton@redhat.com>
