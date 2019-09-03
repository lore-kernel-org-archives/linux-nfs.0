Return-Path: <SRS0=Gfnv=W6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E6EFC3A5A2
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 19:06:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DEBD821897
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 19:06:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725955AbfICTGw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Sep 2019 15:06:52 -0400
Received: from mx1.math.uh.edu ([129.7.128.32]:39344 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725883AbfICTGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Sep 2019 15:06:51 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx1.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1i5E8P-0006ab-O8; Tue, 03 Sep 2019 14:06:48 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id A5F6B801554; Tue,  3 Sep 2019 14:06:33 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     Wolfgang Walter <linux@stwm.de>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, km@cm4all.com,
        linux-kernel@vger.kernel.org
Subject: Re: Regression in 5.1.20: Reading long directory fails
References: <ufak1bhyuew.fsf@epithumia.math.uh.edu>
        <ufay2zduosz.fsf@epithumia.math.uh.edu>
        <ufa5zm9s7kz.fsf@epithumia.math.uh.edu> <4418877.15LTP4gqqJ@stwm.de>
Date:   Tue, 03 Sep 2019 14:06:33 -0500
In-Reply-To: <4418877.15LTP4gqqJ@stwm.de> (Wolfgang Walter's message of "Tue,
        03 Sep 2019 20:02:50 +0200")
Message-ID: <ufapnkhqjwm.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "WW" == Wolfgang Walter <linux@stwm.de> writes:

WW> What filesystem do you use on the server? xfs?

Yeah, it's XFS.

WW> If yes, does it use 64bit inodes (or started to use them)?

These filesystems aren't super old, and were all created with the
default RHEL7 options.  I'm not sure how to check that 64 bit inodes are
being used, though.  xfs_info says:

meta-data=/dev/mapper/nas-faculty--08 isize=256    agcount=4, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=13107200, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal               bsize=4096   blocks=6400, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

WW> Do you set a fsid when you export the filesystem?

I have never done so on any server.

And note that the servers are basically unchanged for quite some time,
while the problem I'm having is new.  I want to find some server-related
cause for this but so far I haven't been able to do so.  It seems my
best option now seems to be to migrate all data off of this server and
then wipe, reinstall and see if the problem reoccurs.

 - J<
