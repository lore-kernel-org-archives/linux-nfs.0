Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC158C04EBF
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 13:53:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8502C20659
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 13:53:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8502C20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726377AbeLDNxU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 08:53:20 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:41197 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726356AbeLDNxU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 08:53:20 -0500
Received: by mail-vs1-f68.google.com with SMTP id t17so9814888vsc.8;
        Tue, 04 Dec 2018 05:53:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=eKdG+iTjuP1kZgJ6VlVsCsbtPXtiOHTWrPRmZYvCpb8=;
        b=r9wbXzE7pF9o+wKf4dOFFBx3+kdknDJdG5CMwl9dOpbYrOUHuK6zYIPO2bvQJWhv06
         +/rvDtYfcunotEi4dNNIndBRUcjOAod9juI4G1Up7KoksodBXIF9A61GPSLaF+qVovst
         dYLTSY9SZPnMyQWw8WGUw10czKdE/fGXCEAEIY7ih2uFvjeDWsstZCdyyk8uKi4MDU/i
         fVDPPGrNNFYpQv8/1KQfU2mC8jLcTPj9qgJEdU+49BED7LsUv55W6DvEGvucZiPeZ99P
         EEBX6IFQjJgV+rhr7YSTzlw7/Z64sRVCBQZZNg5eC/Vko7YlkaODor7SezT+REt6ZEM9
         igfA==
X-Gm-Message-State: AA+aEWao7Fg2ubnfSL5HpZB14SIJbeJmfa8IUS7pK4qOZWLJD7V9Mhz3
        +jn6gnVB4tg8cATt1xOsYkXXIR8cMSGpXyRHChk=
X-Google-Smtp-Source: AFSGD/WcSuKguQiZ3qH9eVDQTuYNYmLt5GKT7zt1AwQyhjxt0C2HtZ8PqftappIv1996JGCVNoePlrbA6pSQTRkQhEI=
X-Received: by 2002:a67:f43:: with SMTP id 64mr8946495vsp.166.1543931599318;
 Tue, 04 Dec 2018 05:53:19 -0800 (PST)
MIME-Version: 1.0
From:   Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Tue, 4 Dec 2018 14:53:07 +0100
Message-ID: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
Subject: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        linux-mips@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

        Hi Trond,

Recently, I've upgraded my NFS server to Ubuntu 18.04LTS.  Apparently
the NFS server in that release dropped support for NFS over UDP, hence I
appended ",tcp,v3" to all my nfsroot kernel command line parameters.
This works fine on my arm/arm64 development boards, but causes a crash
on RBTX4927:

    VFS: Mounted root (nfs filesystem) on device 0:13.
    devtmpfs: mounted
    Freeing prom memory: 1020k freed
    Freeing unused kernel memory: 208K
    This architecture does not have kernel memory protection.
    Run /sbin/init as init process
    do_page_fault(): sending SIGSEGV to init for invalid read access
from 57e7e414
    epc = 77f9e188 in ld-2.19.so[77f9c000+22000]
    ra  = 77f9d91c in ld-2.19.so[77f9c000+22000]
    Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

I found similar crashes in a report from 2006, but of course the code
has changed too much to apply the solution proposed there
(https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html).

Userland is Debian 8 (the last release supporting "old" MIPS).
My kernel is based on v4.20.0-rc5, but the issue happens with v4.20-rc1,
too.

However, I noticed it works in v4.19! Hence I've bisected this, to commit
277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by switching to using
iterators").

Dropping the ",tcp" part from the nfsroot parameter also fixes the issue.

Given RBTX4926 is little endian, just like my arm/arm64 boards, it's probably
not an endianness issue.  Sparse didn't show anything suspicious before/after
the guilty commit.

Do you have a clue?
Thanks!

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
