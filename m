Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44124 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755207Ab0H3QTV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:19:21 -0400
From: Olaf Kirch <okir@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
Date: Mon, 30 Aug 2010 18:19:18 +0200
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Steve Dickson <SteveD@redhat.com>
References: <201008301503.19783.okir@suse.de> <30F1122D-13FB-4B6B-9BA2-99112306581F@oracle.com>
In-Reply-To: <30F1122D-13FB-4B6B-9BA2-99112306581F@oracle.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201008301819.18773.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Monday 30 August 2010 17:59:18 Chuck Lever wrote:
> I worried at the time that this might introduce a security weakness, since,
>  after all, the rpcbind SET operation goes over AF_UNIX, which is
>  authenticated, but pmap uses sockets with privileged ports to detect
>  authorized users.  I see that your logic uses the pmap SET/UNSET calls by
>  default. This bypasses AF_UNIX completely in pretty much all local cases,

That is admittedly a problem, at least for services not running as root.
For services running as root, there's no change in behavior when talking
to rpcbind - the registration will be owned by the superuser in both
cases, because instead of checking the AF_LOCAL credentials for uid 0 it
will check for a privileged source port. I agree though, that this part of
the patch doesn't leave me totally at ease.

>  which changes the behavior of rpcb_set() and rpcb_unset(), and could break
>  the local rpcbind security model.  It might be better to use
>  pmap_setunset() only when local_rpcb() fails.

If it helps, I could do the old PMAP calls as a fallback rather than
trying these by default, agreed. Let me see what I can come up with
tomorrow.

> Another minor problem I think I remember is that if libtirpc is used on a
>  system (perhaps because it is statically linked with said ISV RPC-enabled
>  application) that does not have /etc/netconfig installed, the transport
>  creation logic in rpcb_clnt.c simply doesn't work.

Well, but that's something that's fixed easily - we can always tell
such customer to install an /etc/netconfig on their system.

Olaf
-- 
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)
