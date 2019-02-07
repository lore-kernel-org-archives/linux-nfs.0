Return-Path: <SRS0=BC+Y=QO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 127CAC282C4
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 11:48:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE0DD2080A
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 11:48:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726960AbfBGLso (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 06:48:44 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:52587 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726579AbfBGLso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 06:48:44 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: buczek)
        by mx.molgen.mpg.de (Postfix) with ESMTPSA id 73F2260C3DA99;
        Thu,  7 Feb 2019 12:48:41 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
Subject: 4.0 client and server restart with decreased lease time
To:     linux-nfs@vger.kernel.org
Cc:     it+nfs@molgen.mpg.de
Message-ID: <480bf69d-4651-aaac-2b85-634561c579c8@molgen.mpg.de>
Date:   Thu, 7 Feb 2019 12:48:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The nfsd default lease time has been changed from 90 seconds to 45
seconds between Linux 4.14 and 4.19 by commit d6ebf5088f09 ("nfsd4:
return default lease period").

After we did an upgrade of a nfs server from 4.14 to 4.19, we noticed
a failing process and dmesg logs "NFS: nfs4_reclaim_open_state: Lock
reclaim failed!" on a client (Linux 4.14.87). The client had the
file system mounted with vers=4.0.

Network trace indicated, that the client continued to use the
90 seconds lease period of the previous server incarnation and
sent RENEWs every 60 seconds (2/3 of 90 seconds).  Sometimes the
server answered with NFS4ERR_EXPIRED.

When this happened, the client executed recovery (SETCLIENTID...) but
did non query the server for a new lease_time.  So the problem was
persistent even after the first failure.

As an experiment, I've also restarted a server with the lease time
decrement from 90 to 45 seconds, but the grace period fixed to
90 seconds. Now the client got NFS4ERR_STALE_CLIENTID  but still did
not query the server for a new lease_time and continued to send RENEWs
in 60 second intervals.

At least for the later case, the RFC say, a client should refetch
the lease_time:

> A server may, upon restart, establish a new value for the lease
> period.  Therefore, clients should, once a new client ID is
> established, refetch the lease_time attribute and use it as the basis
> for lease renewal for the lease associated with that server.
> However, the server must establish, for this restart event, a grace
> period at least as long as the lease period for the previous server
> instantiation.  This allows the client state obtained during the
> previous server instance to be reliably re-established.

[ https://tools.ietf.org/html/rfc7530 ]

I understand that a restart with a grace period smaller than the
previous lease time is never save.

Aside from that, is a server restart with a decreased lease time
supposed to be supported by the Linux client? If not, this is kind
of a trap for server upgrades when just relying on the defaults.

Best
   Donald
