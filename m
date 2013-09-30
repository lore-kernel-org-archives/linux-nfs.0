Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637Ab3I3Pvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 11:51:48 -0400
Date: Mon, 30 Sep 2013 11:53:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Michael Gliwinski <Michael.Gliwinski@henderson-group.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: gss context cache
Message-ID: <20130930115318.630391fb@corrin.poochiereds.net>
In-Reply-To: <20130930150013.GH16579@fieldses.org>
References: <1702585.AG7n1MCr0K@hgis96>
	<20130930100000.70578c80@tlielax.poochiereds.net>
	<20130930150013.GH16579@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Sep 2013 11:00:13 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 30, 2013 at 10:00:00AM -0400, Jeff Layton wrote:
> > On Mon, 30 Sep 2013 13:06:47 +0100
> > Michael Gliwinski <Michael.Gliwinski@henderson-group.com> wrote:
> > 
> > > Hi all,
> > > 
> > > On RHEL6 nfs-utils-1.2.3-36
> > > 
> > > man rpc.gssd says it -t wasn't specified then kernel gss contexts will be 
> > > cached for the lifettime of the Kerberos service ticket used in its creation.  
> > > Is there a way to see the contexts + service tickets in that cache?
> > > 
> > 
> > No, AFAIK.
> > 
> > > Also, is there any way short of rebooting the client to evict one entry from 
> > > that cache, or even clear the cache entirely?
> > > 
> > 
> > There is a gss_destroy_creds script which ships as part of nfs-utils.
> > That should basically do what you need, but it's not well-documented so
> > you'll have to play with it some...
> 
> My memory is that depended on some undocumented feature of the upcall
> since removed.  (Maybe the ability to send a downcall that isn't a
> response to some upcall?)  But I may be misremembering.  Somebody should
> probably check and remove that script (and gss_cltn_send_err) if I'm
> right.
> 

Thanks, good to know. I have some other work on my plate for gssd in the
near future, so I'll plan to have a look at that as well.

-- 
Jeff Layton <jlayton@redhat.com>
