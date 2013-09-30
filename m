Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754842Ab3I3PAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 11:00:19 -0400
Date: Mon, 30 Sep 2013 11:00:13 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: Michael Gliwinski <Michael.Gliwinski@henderson-group.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: gss context cache
Message-ID: <20130930150013.GH16579@fieldses.org>
References: <1702585.AG7n1MCr0K@hgis96>
 <20130930100000.70578c80@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130930100000.70578c80@tlielax.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 10:00:00AM -0400, Jeff Layton wrote:
> On Mon, 30 Sep 2013 13:06:47 +0100
> Michael Gliwinski <Michael.Gliwinski@henderson-group.com> wrote:
> 
> > Hi all,
> > 
> > On RHEL6 nfs-utils-1.2.3-36
> > 
> > man rpc.gssd says it -t wasn't specified then kernel gss contexts will be 
> > cached for the lifettime of the Kerberos service ticket used in its creation.  
> > Is there a way to see the contexts + service tickets in that cache?
> > 
> 
> No, AFAIK.
> 
> > Also, is there any way short of rebooting the client to evict one entry from 
> > that cache, or even clear the cache entirely?
> > 
> 
> There is a gss_destroy_creds script which ships as part of nfs-utils.
> That should basically do what you need, but it's not well-documented so
> you'll have to play with it some...

My memory is that depended on some undocumented feature of the upcall
since removed.  (Maybe the ability to send a downcall that isn't a
response to some upcall?)  But I may be misremembering.  Somebody should
probably check and remove that script (and gss_cltn_send_err) if I'm
right.

--b.
> 
> > (looking for this as I had situations where access was denied by the NFS 
> > server and I could see the principal was getting mapped to nfsnobody, etc. and 
> > was suspecting the account was changed on the KDC and the old context/ticket 
> > may have been causing problems)
> > 
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
