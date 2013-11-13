Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50704 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652Ab3KMEHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 23:07:21 -0500
Received: by mail-wi0-f178.google.com with SMTP id hn6so205120wib.11
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 20:07:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <29447.1383230746@obiwan.sandelman.ca>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
	<20131031141538.GA621@fieldses.org>
	<29447.1383230746@obiwan.sandelman.ca>
Date: Wed, 13 Nov 2013 09:37:20 +0530
Message-ID: <CA+uAZNNS+dBom1CWh8rGAzLnXc5kEsq80LpH-X_EJ_cV6HHP+w@mail.gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Can you pls suggest how we can formalize this hack into a proper fix?

Thanks.

--Shyam

On Thu, Oct 31, 2013 at 8:15 PM, Michael Richardson <mcr@sandelman.ca> wrote:
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
>
> --
> ]               Never tell me the odds!                 | ipv6 mesh networks [
> ]   Michael Richardson, Sandelman Software Works        | network architect  [
> ]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [
>
>
>
>
>
