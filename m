Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755226Ab3JaPOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 11:14:43 -0400
Date: Thu, 31 Oct 2013 11:14:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Richardson <mcr@sandelman.ca>
Cc: linux-nfs@vger.kernel.org, Shyam Kaushik <shyamnfs1@gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131031151442.GB621@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
 <20131031141538.GA621@fieldses.org>
 <29447.1383230746@obiwan.sandelman.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <29447.1383230746@obiwan.sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 31, 2013 at 10:45:46AM -0400, Michael Richardson wrote:
> 
>     >> I am chasing a NFS server performance issue on Ubuntu
>     >> 3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
>     >> server.
> 
> I have been also trying to figure out NFS performance issues at my home
> office.  Server is ubuntu precise (3.2.0-55, old, true) kernel, and clients
> are mostly a mix of Debian versions (mostly virtualized XEN).
> GbE over a VLAN is setup just for storage, and mostly IPv6 connections.
> 
> J. Bruce Fields <bfields@fieldses.org> wrote:
>     > Would you be willing to test an upstream kernel and/or some patches?
>     > Sounds like you're using only NFSv4?
> 
> I'm also willing to; my preference would be to build a generic 3.10 or 3.11
> kernel with NFS as a module, and then update the NFS code, but I
> haven't gotten around to scheduling some time to reboot a bunch.
> 
> What I observe is huge TCP send queues on the server and what appears to be
> head of queue blocking on the client.  This looks like a client issue to me,
> and for at least one client (my mpd/shoutcast server), I'm happy to reboot
> it regularly... I notice the NFS delays because the music stops :-)
> 
> There are some potential instabilities in frequency of IPv6 Router
> Advertisements due to a bug in the CeroWRT, which initially I was blaming,
> but I'm no longer convinced, since it happens over IPv4 on the storage VLAN
> too.
> 
> Shyam, please share with me your testing strategy.

Your problem sounds different; among other things, it's with reads
rather than writes.

Yes, testing with a recent upstream kernel would be a good start.  3.11
or more recent would be ideal as there was a fix for read deadlocks
there (which I doubt you're hitting, but would be nice to rule it out).

--b.
