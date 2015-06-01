Return-Path: <bfields@fieldses.org>
Date: Mon, 1 Jun 2015 16:36:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, smayhew@redhat.com
Subject: Re: [PATCH pynfs 0/3] MITM tool for NFS traffic on linux
Message-ID: <20150601203601.GE26972@fieldses.org>
References: <cover.1432749206.git.bcodding@redhat.com>
 <alpine.OSX.2.19.9992.1505271403070.53081@planck.local>
 <20150601181217.GB26489@fieldses.org>
 <alpine.OSX.2.19.9992.1506011420560.53081@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1506011420560.53081@planck.local>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 01, 2015 at 02:25:45PM -0400, Benjamin Coddington wrote:
> On Mon, 1 Jun 2015, J. Bruce Fields wrote:
> 
> > On Wed, May 27, 2015 at 02:03:56PM -0400, Benjamin Coddington wrote:
> > > On Wed, 27 May 2015, Benjamin Coddington wrote:
> > >
> > > > What follows is a small tool I think may be convenient to test and reproduce
> > > > certain types of bugs that are difficult to create from above the
> > > > filesystem, but are clearly problematic and have well-defined network
> > > > triggers.  Anna's recent BAD_STATEID on WRITES with delegation is a good
> > >
> > > *Olga
> > >
> > > Apologies.
> > >
> > > Ben
> > >
> > > > example of that.  This tool uses netfilters NFQUEUE target to allow a linux
> > > > host to modify the NFS network traffic between existing clients and servers.
> > > > In that sense, it is very similar to nfs-proxy, however I find it to be much
> > > > more convenient to use, as it can be quickly inserted and removed from an
> > > > existing network conection.
> >
> > By the way, I only recently noticed there's a branch of Fred's old pynfs
> > repo with the proxy-nfs code.  I've just merged that branch into my
> > tree.  (Let me know if anyone uses that.)
> >
> > Do you want me to take these patches to?  Do you think you're going to
> > continue using this?
> 
> I'm actually not sure yet if this is more or less useful than the
> nfs-proxy..   In using it the past week, I found it to be convenient for
> quickly inserting and removing behaviors, and then modifiying those
> behaviors and quickly inserting/removing them again.  I think doing that
> with the nfs-proxy would be more disruptive to the client, potentially.
> 
> It does suffer from a scrambling of TCP sequencing if payload sizes are
> modified - the nfs-proxy doesn't have this problem.  That causes the
> transport to want to reconnect.. so when using it you have to keep TCP in
> mind.

Sounds a little scary.

> I think I'll continue to use what I have and do a bit of refinement and post
> back again in a bit.

OK.

--b.
