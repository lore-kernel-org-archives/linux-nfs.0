Return-Path: <SRS0=E79I=VQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8EA8C7618F
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Jul 2019 18:18:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 89E72204EC
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Jul 2019 18:18:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729317AbfGSSSE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Jul 2019 14:18:04 -0400
Received: from fieldses.org ([173.255.197.46]:58526 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728461AbfGSSSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Jul 2019 14:18:04 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 9C9C41C89; Fri, 19 Jul 2019 14:18:03 -0400 (EDT)
Date:   Fri, 19 Jul 2019 14:18:03 -0400
To:     John Bartoszewski <john.bartoszewski@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: zfs server slow mounting ( mtab ?)
Message-ID: <20190719181803.GA21002@fieldses.org>
References: <CAMttjSSQibhZ4ekSMVRF0jeREA9n9s6puAJcOTR2vyn=W2W5sg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMttjSSQibhZ4ekSMVRF0jeREA9n9s6puAJcOTR2vyn=W2W5sg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jul 05, 2019 at 04:59:02PM -0600, John Bartoszewski wrote:
> I'm trying to setup a nfs server with over 3500+ zfs datasets
> being exported. Only NFSv3 is needed.
> 
> The OS had a 4.4.172 kernel and nfs-utils 1.30. With these versions
> when a client tried to mount an exported dataset, rpc.mountd spiked to
> 100% for several minutes, the kernel produced a bug and a trace
> output, and the client never finished.
> 
> I have built a 4.19.56 kernel, libevent 2.1.10, util-linux 2.34 (for
> libblkid), and nfs-utils 2.4.1. With this setup rpc.mountd does spike
> to 100%, but at least a mount finishes, but it takes about 5 minutes.

Have you experimented with the --num-threads option?  If so, did it
help?

> nfs-utils was configured with:
> ./configure --disable-tirpc  --disable-nfsv4 --disable-nfsv41
> --disable-gss --disable-ipv6
> 
> Stracing the new rpc.mountd it appears all the time is spent reading
> the mtab.
> 
> Below is some of the output from:
> /sbin/rpc.mountd --foreground --debug all
> 
> rpc.mountd: nfsd_fh: found 0x6173d50 path /
> rpc.mountd: auth_unix_ip: inbuf 'nfsd 10.222.33.24'
> rpc.mountd: auth_unix_ip: client 0x1d5bbb0 '10.222.33.0/24'
> rpc.mountd: auth_unix_ip: inbuf 'nfsd 10.222.33.254'
> rpc.mountd: auth_unix_ip: client 0x1d5bbb0 '10.222.33.0/24'
> rpc.mountd: nfsd_export: inbuf '10.222.33.0/24 /nfsexport'
> rpc.mountd: nfsd_export: found 0x6174260 path /nfsexport
> rpc.mountd: nfsd_fh: inbuf '10.222.33.0/24 7
> \x43000a00000000001ce354a654a34fd4a09f9b59f6aebb11'
> rpc.mountd: nfsd_fh: found 0x6174270 path /nfsexport
> rpc.mountd: nfsd_export: inbuf '10.222.33.0/24 /nfsexport/home'
> rpc.mountd: nfsd_export: found 0x4cf8bc0 path /nfsexport/home
> rpc.mountd: Received NULL request from 10.222.33.254
> rpc.mountd: Received NULL request from 10.222.33.254
> rpc.mountd: Received MNT3(/nfsexport/home/timmy) request from 10.222.33.254
> rpc.mountd: authenticated mount request from 10.222.33.254:694 for
> /nfsexport/home/timmy (/nfsexport/home/timmy)
> rpc.mountd: nfsd_fh: inbuf '10.222.33.0/24 6 \x947e3e1400c9c79b0000000000000000'
> rpc.mountd: nfsd_fh: found 0x4e54390 path /nfsexport/home/timmy
> 
> As you can see it searches for /, then /nfsexport, then /nfsexport/home,
> and finally /nfsexport/home/timmy
> 
> But when zfs populates the mtab, the top level of the datasets
> ( /nfsexport ) is at the bottom of the mtab, 3500 lines down.
> The next level is also at the bottom. So getmntent has to
> read the mtab stream through several times. Actually:
> open("/etc/mtab", O_RDONLY|O_CLOEXEC)   = 10
> is called 50000 times during this one mount attempt.

I haven't looked at the v3 mountd code in a while.  I guess the next
step would be to figure out what the rest of the call stack is--who's
calling getmntent and why?

--b.
