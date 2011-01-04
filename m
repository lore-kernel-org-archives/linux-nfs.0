Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48491 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065Ab1ADXSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:18:14 -0500
Date: Tue, 4 Jan 2011 18:18:10 -0500
From: "Dr. J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSv4: Send unmapped uid/gids to the server when
 using auth_sys
Message-ID: <20110104231810.GA14381@fieldses.org>
References: <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291085863-3234-4-git-send-email-Trond.Myklebust@netapp.com>
 <1291085863-3234-5-git-send-email-Trond.Myklebust@netapp.com>
 <20110104212504.GG27727@hostway.ca>
 <1294176792.5896.22.camel@heimdal.trondhjem.org>
 <20110104214334.GI27727@hostway.ca>
 <1294177833.5896.26.camel@heimdal.trondhjem.org>
 <20110104215731.GH7908@fieldses.org>
 <1294178391.5896.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294178391.5896.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 04:59:51PM -0500, Trond Myklebust wrote:
> On Tue, 2011-01-04 at 16:57 -0500, Dr. J. Bruce Fields wrote: 
> > On Tue, Jan 04, 2011 at 04:50:33PM -0500, Trond Myklebust wrote:
> > > On Tue, 2011-01-04 at 13:43 -0800, Simon Kirby wrote: 
> > > > On Tue, Jan 04, 2011 at 04:33:12PM -0500, Trond Myklebust wrote:
> > > > 
> > > > > On Tue, 2011-01-04 at 13:25 -0800, Simon Kirby wrote: 
> > > > > > I finally got around to setting up idmapd properly with libnss-mysql, and
> > > > > > in doing so, I forgot that I had enabled nfs4_disable_idmapping=Y with
> > > > > > this patch applied.  With this option set on the client, and the server
> > > > > > set up normally, I get EINVAL from chown's fchowna():
> > > > > > 
> > > > > > # chown testuser:testuser test
> > > > > > chown: changing ownership of `test': Invalid argument
> > > > > > # echo N > /sys/module/nfs/parameters/nfs4_disable_idmapping
> > > > > > # chown testuser:testuser test
> > > > > > #
> > > > > > 
> > > > > > This happened on 2.6.37-rc5-git4, but I just reproduced it with
> > > > > > 2.6.37-rc8-git5 as well.  The server idmapd logs:
> > > > > > 
> > > > > > rpc.idmapd[2987]: nss_getpwnam: name '1009999' does not map into domain 'localdomain'
> > > > > > rpc.idmapd[2987]:  Server: (user) name "1009999" -> id "65534"
> > > > > > rpc.idmapd[2987]: nfsdcb: authbuf=10.10.52.0/24 authtype=group
> > > > > > rpc.idmapd[2987]:  Server: (group) name "1009999" -> id "65534"
> > > > > > 
> > > > > > (1009999 is the current uid/gid here.)
> > > > > > 
> > > > > > I think you meant for this to fall back automatically, right?
> > > > > 
> > > > > Did you remember to apply the patch 'NFSv4: Propagate the error
> > > > > NFS4ERR_BADOWNER to nfs4_do_setattr'?
> > > > 
> > > > Yes, that patch is applied as part of the series. 
> > > > 
> > > > The -EINVAL is going back to userland's fchownat().  I expected
> > > > to see the "Reenabling the idmapper" printk() from within
> > > > nfs4_handle_exception(), but this didn't seem to happen.
> > > 
> > > Hmm... Bruce, does the server actually return NFS4ERR_BADOWNER when it
> > > is supposed to? As far as I can see, nfs4idmap will consistently return
> > > NFS4ERR_BADNAME, which would be a bug here.
> > 
> > Whoops.  Looking at the spec....  Looks like BADNAME should be reserved
> > only for filenames?  I'll fix that now.
> 
> Sigh... I'll fix up the client patches to work around the server bug...

Apologies.  Well, it's unambiguous enough, so hopefully it shouldn't
cause problems....

Server fix follows.  The first patch is all that matters, the rest is
some cleanup I noticed while I was there.

--b.
