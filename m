Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25222 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3BBG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 20:01:06 -0500
Message-ID: <1322614863.11286.106.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com, Garth Gibson <garth@panasas.com>,
        Marc Eshel <eshel@almaden.ibm.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Date: Tue, 29 Nov 2011 20:01:03 -0500
In-Reply-To: <987731612.394.1322614086868.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <987731612.394.1322614086868.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 19:48 -0500, Matt W. Benjamin wrote: 
> Let me clarify: there are files based servers, our Ceph on Ganesha server is one, which have file allocation not satisfied by whole-file layouts.  I would think that demonstrating this would be sufficient to get support from the Linux client to support appropriate segment management, at any rate, if someone is willing to write and support the required code, or already has.  One of those alternatives is certainly the case.  By the way, we wrote generic pNFS, pNFS files support for Ganesha and, with a big dose of help from Panasas, are taking it to merge.

I really want more than that. Please see the reply that I just sent to
Boaz: I need a client strategy for managing partial layout segments in
the case where holding a whole-file layout is not acceptable. Otherwise,
what we have now should be sufficient...

Trond

> Matt
> 
> ----- "Matt W. Benjamin" <matt@linuxbox.com> wrote:
> 
> > That would be pretty disappointing.  However, based on previous
> > interactions, my belief would be, the
> > Linux client will do what can be shown empirically to work better, or
> > more correctly.
> > 
> > Matt
> > 
> > ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Tue, 2011-11-29 at 14:40 -0800, Boaz Harrosh wrote:
> > > > On 11/29/2011 01:57 PM, Trond Myklebust wrote:
> > > > >> Also Files when they will support segments and servers that
> > > request segments,
> > > > >> like the CEPH server, will very much enjoy the above, .i.e:
> > Tell
> > > me the amount
> > > > >> you know you want to write.
> > > > >
> > > > > Why would we want to add segment support to the pNFS files
> > > client???
> > > > > Segments are a nuisance that multiply the amount of unnecessary
> > > chitchat
> > > > > between the client and the MDS without providing any tangible
> > > > > benefits...
> > > > >
> > > >
> > > > Your kidding right?
> > > >
> > > > One: it is mandated by the Standard, This is not an option. So a
> > > perfectly
> > > >      Standard complaint server is not Supported by Linux because
> > we
> > > don't see
> > > >      the point.
> > >
> > > Bollocks.. Nothing is "mandated by the Standard". If the server
> > > doesn't
> > > give us a full layout, then we fall back to write through MDS. Why
> > > dick
> > > around with crap that SLOWS YOU DOWN.
> > >
> > > > Two: There are already file-layout servers out there (multiple)
> > > which are
> > > >      waiting for the Linux files-layout segment support, because
> > the
> > > underline
> > > >      FS requires Segments and now they do not work with the Linux
> > > client. These
> > > >      are CEPH and GPFS and more.
> > >
> > > Then they will have a _long_ wait....
> > >
> > > Trond
> > >
> > > --
> > > Trond Myklebust
> > > Linux NFS client maintainer
> > >
> > > NetApp
> > > Trond.Myklebust@netapp.com
> > > www.netapp.com
> > 
> > --
> > 
> > Matt Benjamin
> > 
> > The Linux Box
> > 206 South Fifth Ave. Suite 150
> > Ann Arbor, MI  48104
> > 
> > http://linuxbox.com
> > 
> > tel. 734-761-4689
> > fax. 734-769-8938
> > cel. 734-216-5309
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

