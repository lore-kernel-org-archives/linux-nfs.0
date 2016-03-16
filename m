Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33696 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966715AbcCPPjQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2016 11:39:16 -0400
Received: by mail-lb0-f169.google.com with SMTP id oe12so50720432lbc.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 08:39:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160316150510.GE11520@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
 <20160315131959.GA419@fieldses.org> <87vb4nh406.fsf@notabene.neil.brown.name>
 <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com> <20160316150510.GE11520@fieldses.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 16 Mar 2016 16:38:55 +0100
Message-ID: <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall()
 detects a race
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Thank your for your reply.

On Wed, Mar 16, 2016 at 4:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Why is that?

It's indeed not really based on actual proof but based on the experience we had.
Faced several bugs, and it appears we had less issues by backporting a
few commits; e.g related to races, leaks, performances regressions. We
did not spent enough time on it to actually show this commit was
actually fixing an issue hit.

> Do you have a list?

I am currently trying to switch from v3.14 to v4.1 (nfs client). So
even know it is off topic, those I have in mind:
0d2a970 SUNRPC: Fix a backchannel race
6851447 SUNRPC: Fix a backchannel deadlock
0993920 SUNRPC: Prevent SYN+SYNACK+RST storms
03c78827 SUNRPC: Fix races between socket connection and destroy code
a41cbe8 Failing to send a CLOSE if file is opened WRONLY and server
reboots on a 4.x mount
39d0d3b NFS: Fix a tracepoint NULL-pointer dereference
5e99b53 nfs4: reset states to use open_stateid when returning
delegation voluntarily
e92c1e0 NFSv4: Fix a nograce recovery hang
6b55970 nfs: Fix a memory leak when meeting an unsupported state protect

I am probably wrong on most of them but we had better stability after
applying them and I probably forgot some.

> I don't expect *proof*, necessarily, but some sort of argument would be
> helpful.

In my environment, if I hit this race, it is not acceptable to not
being able to unmount the filesystem.

Thanks,
-- 
William
