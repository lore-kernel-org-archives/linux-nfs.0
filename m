Return-Path: <smayhew@redhat.com>
Date: Thu, 12 Jul 2018 08:25:36 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "bcodding@redhat.com" <bcodding@redhat.com>,
	"anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
Message-ID: <20180712122536.GJ10135@coeurl.usersys.redhat.com>
References: <20180711122219.20808-1-smayhew@redhat.com>
 <1F59764C-4E7C-4D15-BE35-490D61F0349F@redhat.com>
 <20180711162447.GI10135@coeurl.usersys.redhat.com>
 <9322c4d50a0828c7592beaac2bbca63bc0b12255.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9322c4d50a0828c7592beaac2bbca63bc0b12255.camel@hammerspace.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Jul 2018, Trond Myklebust wrote:

> On Wed, 2018-07-11 at 12:24 -0400, Scott Mayhew wrote:
> > On Wed, 11 Jul 2018, Benjamin Coddington wrote:
> > 
> > > So there's two changes here, the first is that we don't call
> > > nfs_fscache_get_client_cookie() if rpc_ops->init_client fails,
> > > which makes
> > > sense.  The second is that we create separate fscache indexes for
> > > minor
> > > versions.  Why do we need separate caches if the nfs_client is the
> > > same?  I
> > > thought that the nfs_client is just there to have something to hang
> > > the
> > > superblock caches from..
> > > 
> > > Is the problem that we can take down one nfs_client and then
> > > initialize a
> > > new one, but the nfs_server_key is exactly the same, so now we
> > > start to add
> > > new objects before fscache has cleaned up old references?
> > 
> > The nfs_clients aren't the same, and nothing's being torn down.
> > 
> > I'm using steved's "runcthon" script from cthon which performs
> > multiple cthon runs simultaneiously.  I have different superblocks,
> > nfs_servers, nfs_clients, and fscache_cookies.  But the keys for the
> > v4.x mounts are all the same.  David indicated that was problematic,
> > so
> > I suggested adding the minor version to the key, which he said was
> > fine.
> 
> So what is the use case for having a NFSv4 and NFSv4.1 mount of the
> same filesystem? I agree we shouldn't crash, but I'm lost as to why
> someone would want to do this.
> 
> IOW: Why isn't the right thing to do here just to remove the bogus
> BUG_ON()?
>
The bug was originally filed by steved a few years ago and that was his
reproducer.  Looking at some of the customer cases attached to the bug
now, it looks like they're not using different NFS versions... in which
case the patch wouldn't help.  Let me see if there are any vmcores still
available from those cases.

-Scott 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
