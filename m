Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f41.google.com ([209.85.213.41]:37142 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbbBYAJt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2015 19:09:49 -0500
Received: by yhoa41 with SMTP id a41so117394yho.4
        for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2015 16:09:48 -0800 (PST)
Date: Tue, 24 Feb 2015 19:09:43 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew W Elble <aweits@rit.edu>
Cc: Anthony Messina <amessina@messinet.com>,
        Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: soft lockup in the laundromat
Message-ID: <20150224190943.5bec2435@tlielax.poochiereds.net>
In-Reply-To: <m2pp8zj9o7.fsf@discipline.rit.edu>
References: <alpine.OSX.2.19.9992.1502181132520.80359@planck.local>
	<2527473.XPWgOc24eg@linux-ws1.messinet.com>
	<1524803.SbAy9NQUHI@ws1.m.messinet.com>
	<m2pp8zj9o7.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Feb 2015 16:12:40 -0500
Andrew W Elble <aweits@rit.edu> wrote:

> 
> We're running into something very similar.
> 
> 
> fs/nfsd/nfs4state.c:
> 
>   1631  static void
>   1632  __destroy_client(struct nfs4_client *clp)
>   1633  {
> 
>     <snip>   
> 
>   1652          while (!list_empty(&clp->cl_revoked)) {
>   1653                  dp = list_entry(reaplist.next, struct  nfs4_delegation, dl_recall_lru);
>   1654                  list_del_init(&dp->dl_recall_lru);
>   1655                  nfs4_put_stid(&dp->dl_stid);
>   1656          }
> 
>   shouldn't that be:
> 
>   1653                  dp = list_entry(clp->cl_revoked.next, struct  nfs4_delegation, dl_recall_lru);
> 
> see commit 2d4a532d385f635ab8243b88db3136bb52a0bc29
> 
>   ?
> 
> Thanks,
> 
> Andy
> 

(cc'ing Bruce)

Oh my, yes. Well spotted!

That's almost certainly _a_ problem if not _the_ problem. Looks like
commit 2d4a532d3 is what broke it.

Care to spin up a patch? If not, I'll do so as soon as I'm able. That's
almost certainly something that should go to stable as well.

-- 
Jeff Layton <jlayton@poochiereds.net>
