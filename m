Return-Path: <SRS0=zGT5=UK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB42BC43218
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Jun 2019 05:09:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9B8592063F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Jun 2019 05:09:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391165AbfFKFJ0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Jun 2019 01:09:26 -0400
Received: from verein.lst.de ([213.95.11.211]:48045 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2390539AbfFKFJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jun 2019 01:09:26 -0400
Received: by newverein.lst.de (Postfix, from userid 2407)
        id 0547768B05; Tue, 11 Jun 2019 07:08:57 +0200 (CEST)
Date:   Tue, 11 Jun 2019 07:08:56 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     Theodore Ts'o <tytso@mit.edu>, Amir Goldstein <amir73il@gmail.com>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Luis Henriques <lhenriques@suse.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH] vfs: allow copy_file_range from a swapfile
Message-ID: <20190611050856.GA19013@lst.de>
References: <20190610172606.4119-1-amir73il@gmail.com> <20190611011612.GQ1871505@magnolia> <20190611025108.GB2774@mit.edu> <20190611032926.GA1872778@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611032926.GA1872778@magnolia>
User-Agent: Mutt/1.5.17 (2007-11-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jun 10, 2019 at 08:29:26PM -0700, Darrick J. Wong wrote:
> ...and administrators often mkfs over mounted filesystems because we let
> them read and write block devices.  Granted I tried to fix that once and
> LVM totally stopped working...

That must have been a long time ago.  We now overload O_EXCL on
blockdevice to only allow a single exclusive openers, and mounted
filesystems as well as raid drivers have been setting set for at leat
10 years.
