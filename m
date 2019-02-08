Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1053C282C2
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 02:03:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 94F9A2146E
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 02:03:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726801AbfBHCDX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 21:03:23 -0500
Received: from fieldses.org ([173.255.197.46]:55898 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726775AbfBHCDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 21:03:23 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id A36BC1C97; Thu,  7 Feb 2019 21:03:22 -0500 (EST)
Date:   Thu, 7 Feb 2019 21:03:22 -0500
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     linux-nfs@vger.kernel.org, it+nfs@molgen.mpg.de
Subject: Re: 4.0 client and server restart with decreased lease time
Message-ID: <20190208020322.GA9482@fieldses.org>
References: <480bf69d-4651-aaac-2b85-634561c579c8@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480bf69d-4651-aaac-2b85-634561c579c8@molgen.mpg.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 07, 2019 at 12:48:41PM +0100, Donald Buczek wrote:
> The nfsd default lease time has been changed from 90 seconds to 45
> seconds between Linux 4.14 and 4.19 by commit d6ebf5088f09 ("nfsd4:
> return default lease period").
> 
> After we did an upgrade of a nfs server from 4.14 to 4.19, we noticed
> a failing process and dmesg logs "NFS: nfs4_reclaim_open_state: Lock
> reclaim failed!" on a client (Linux 4.14.87). The client had the
> file system mounted with vers=4.0.

Argh.  My fault for changing that default without thinking of the impact
on a server upgrade on existing client mounts, sorry.

> Network trace indicated, that the client continued to use the
> 90 seconds lease period of the previous server incarnation and
> sent RENEWs every 60 seconds (2/3 of 90 seconds).  Sometimes the
> server answered with NFS4ERR_EXPIRED.
>
> When this happened, the client executed recovery (SETCLIENTID...) but
> did non query the server for a new lease_time.  So the problem was
> persistent even after the first failure.

That certainly sounds like a client bug, though.

> As an experiment, I've also restarted a server with the lease time
> decrement from 90 to 45 seconds, but the grace period fixed to
> 90 seconds. Now the client got NFS4ERR_STALE_CLIENTID  but still did
> not query the server for a new lease_time and continued to send RENEWs
> in 60 second intervals.
> 
> At least for the later case, the RFC say, a client should refetch
> the lease_time:
> 
> >A server may, upon restart, establish a new value for the lease
> >period.  Therefore, clients should, once a new client ID is
> >established, refetch the lease_time attribute and use it as the basis
> >for lease renewal for the lease associated with that server.
> >However, the server must establish, for this restart event, a grace
> >period at least as long as the lease period for the previous server
> >instantiation.  This allows the client state obtained during the
> >previous server instance to be reliably re-established.
> 
> [ https://tools.ietf.org/html/rfc7530 ]
> 
> I understand that a restart with a grace period smaller than the
> previous lease time is never save.
> 
> Aside from that, is a server restart with a decreased lease time
> supposed to be supported by the Linux client? If not, this is kind
> of a trap for server upgrades when just relying on the defaults.

The client should be following the RFC and requesting the lease period
again after restart.

With that fixed, it may still fail to reclaim locks in this case, since
the upgraded server isn't providing a 90-second grace period as it
should, but that should at least avoid problems caused by it continuing to
renew only at 60-second intervals.

The server shouldn't have changed the defaults.  The only safe way to
decrease the lease period is to do it from userspace (e.g., change
NFSD_V4_LEASE value in /etc/sysconfig/nfs, restart, wait at least 90
seconds for every client to have a chance to get the new lease time,
then change NFSD_V4_GRACE).  The kernel on its own can't do this safely
since it doesn't know how to find the old value of the lease time.

--b.
