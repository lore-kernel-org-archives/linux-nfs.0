Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33597 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab0K3DYC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 22:24:02 -0500
Subject: Re: [PATCH 0/4] Allow the admin to turn off NFSv4 uid/gid mapping
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101130031507.GA2640@merit.edu>
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20101130031507.GA2640@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 22:24:00 -0500
Message-ID: <1291087440.20567.65.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 22:15 -0500, Jim Rees wrote:
> Trond Myklebust wrote:
> 
>   The following patches allow the admin to turn off NFSv4 uid/gid mapping
>   if mounting using AUTH_SYS security.
>   
>   The new behaviour is enabled using a module parameter,
>   nfs4_disable_idmapping.
> 
> Would this be more useful as a per-mount option rather than a global?

Why? The minute the server rejects it, the option is turned off. The
main reasons I can see for wanting to turn it off at mount time is

1) The server already has a different uid/gid mapping set up
2) The server lies in a different NFS domain.

In either one of those two cases, why would you want to use AUTH_SYS in
the first place? It will be broken.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

