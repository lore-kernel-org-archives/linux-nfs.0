From: Gyorgy Jeney <nog.lkml@gmail.com>
Subject: NFS over RDMA problem: svcrdma: Error fast registering memory for
	xprt ffff8803307d7400
Date: Tue, 13 Jul 2010 10:45:51 +0200
Message-ID: <AANLkTinjZfpICMjP1EcU4CPAe1TwxKp1zsk-lwX6fmzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56536 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab0GMIpx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 04:45:53 -0400
Received: by wyf23 with SMTP id 23so3974797wyf.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 01:45:52 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

Should this mailing-list be the wrong place to ask, I apologise and I
would take it kindly, if someone could then point me to the right forum.

I am attempting to use NFS over RDMA (over infiniband), but there is some
problem.  The NFS filesystem can be mounted on the client, and things
will work for some time (can read, modify, etc. the files over the mount),
but then (at a seemingly random time) the NFS server will dump these
lines to the logs:

[ 4380.623922] svcrdma: Error fast registering memory for xprt ffff8803307d7400
[ 4413.343161] svcrdma: error fast registering xdr for xprt ffff8803319edc00

and the nfs filesystem on the NFS client will be unacessable.  Is this a
known problem?  Do workarounds exist?  Or am I just missing something?


Both client and server are running the latest vanilla 2.6.34.1 kernel
with Mellanox Connect-X infiniband cards.  If more information is
required, please do ask.

BTW: I can reproduce the problem quite reliably by running the bonnie++
"benchmark" on the NFS mounted filesystem.

nog.

ps: I'm not subscribed to the list, please CC me on all replies.
