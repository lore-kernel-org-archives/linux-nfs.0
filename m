Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49489 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207Ab0IGU6Y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 16:58:24 -0400
From: Olaf Kirch <okir@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
Date: Tue, 7 Sep 2010 22:58:21 +0200
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Steve Dickson <SteveD@redhat.com>
References: <201008301503.19783.okir@suse.de> <201009071327.07291.okir@suse.de> <F1D592E6-35AD-45DA-B69E-044D59500DFB@oracle.com>
In-Reply-To: <F1D592E6-35AD-45DA-B69E-044D59500DFB@oracle.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201009072258.22044.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 07 September 2010 17:36:58 Chuck Lever wrote:
> Probably not a bad idea.  But I thought this was a problem for applications
>  that are calling rpcb_{un,}set(3t), not apps that are invoking the legacy
>  variants.  How does this new patch address the problem?

No, it's a problem with legacy apps calling pmap_set/unset. They simply
stop working if you use pmap_set + libtirpc + portmap.

> What happens if you try the other way around: try the AF_UNIX mechanism
>  first, then the legacy mechanism?  It's arguable that any application
>  calling the pmap_{un,}set(3t) interface would likely expect the old
>  behavior anyway, but could probably benefit from the additional security
>  if rpcbind, rather than portmap, is running locally.

I don't think apps coded to the old pmap_* interface will benefit
in any way from the new security model. These services expect a
root/non-root split of privilege, and that's what they get with
PMAP_SET/UNSET, no matter whether they talk to rpcbind or portmap.

>   1.  rpcb_{un,}set(3t) need to work whether rpcbind or portmapper are
>  running 2.  pmap_{un,}set(3t) should still invoke rpcb_{un,}set(3t) under
>  the covers to ensure they get advanced security when available
> 
> This is because you can build legacy apps against libtirpc (which want
>  robust pmap_{un,}set(3t) no matter which portmapper is running), but you
>  can also construct TI-RPC enabled apps that may be running on a system
>  with only portmap (which want robust rpcb_{un,}set(3t)).  So I think you
>  have to fix both APIs.

The latter is a problem indeed, and I guess we need to fix it as well.
The one that I wanted to address first and foremost is applications
using the legacy API

Olaf
-- 
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)
