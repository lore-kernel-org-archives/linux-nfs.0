Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45889 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757003Ab3KMQSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 11:18:34 -0500
Date: Wed, 13 Nov 2013 11:18:32 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Shyam Kaushik <shyamnfs1@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131113161832.GJ28033@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
 <20131031141538.GA621@fieldses.org>
 <29447.1383230746@obiwan.sandelman.ca>
 <CA+uAZNNS+dBom1CWh8rGAzLnXc5kEsq80LpH-X_EJ_cV6HHP+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+uAZNNS+dBom1CWh8rGAzLnXc5kEsq80LpH-X_EJ_cV6HHP+w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 09:37:20AM +0530, Shyam Kaushik wrote:
> Hi Bruce,
> 
> Can you pls suggest how we can formalize this hack into a proper fix?

Apologies, I delayed responding while trying to decide if an xdr rewrite
was ready for this merge window--it looks definitely not, so I'm just
going to go with the "PAGE_SIZE for all but read" hack in
nfsd4_decode_compound for now, with just slightly better documentation.

--b.

> 
> Thanks.
> 
> --Shyam
> 
> On Thu, Oct 31, 2013 at 8:15 PM, Michael Richardson <mcr@sandelman.ca> wrote:
> >
> >     >> I am chasing a NFS server performance issue on Ubuntu
> >     >> 3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
> >     >> server.
> >
> > I have been also trying to figure out NFS performance issues at my home
> > office.  Server is ubuntu precise (3.2.0-55, old, true) kernel, and clients
> > are mostly a mix of Debian versions (mostly virtualized XEN).
> > GbE over a VLAN is setup just for storage, and mostly IPv6 connections.
> >
> > J. Bruce Fields <bfields@fieldses.org> wrote:
> >     > Would you be willing to test an upstream kernel and/or some patches?
> >     > Sounds like you're using only NFSv4?
> >
> > I'm also willing to; my preference would be to build a generic 3.10 or 3.11
> > kernel with NFS as a module, and then update the NFS code, but I
> > haven't gotten around to scheduling some time to reboot a bunch.
> >
> > What I observe is huge TCP send queues on the server and what appears to be
> > head of queue blocking on the client.  This looks like a client issue to me,
> > and for at least one client (my mpd/shoutcast server), I'm happy to reboot
> > it regularly... I notice the NFS delays because the music stops :-)
> >
> > There are some potential instabilities in frequency of IPv6 Router
> > Advertisements due to a bug in the CeroWRT, which initially I was blaming,
> > but I'm no longer convinced, since it happens over IPv4 on the storage VLAN
> > too.
> >
> > Shyam, please share with me your testing strategy.
> >
> > --
> > ]               Never tell me the odds!                 | ipv6 mesh networks [
> > ]   Michael Richardson, Sandelman Software Works        | network architect  [
> > ]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [
> >
> >
> >
> >
> >
