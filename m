Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC27FC004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 23:39:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D8D220674
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 23:39:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D8D220674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726819AbeJWH7o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 03:59:44 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:41145 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726804AbeJWH7o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 03:59:44 -0400
Received: by mail-qt1-f194.google.com with SMTP id l41-v6so48485408qtl.8
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 16:39:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=XotdFdVk73hvMQmfL42APXxnKTqdLawi1M4laqBx2jw=;
        b=sdMpaL5YQEMnslGqGbl3OgEVRnooqO/lcXMGOpUDRTAWtwyGGjE4eO+9bC9vVNlsfF
         GG6xJw42ze0XYv7DM1Or5vmP4rRF0L8nNupSGdLKaIFFuTuuEOhf6T+Bvl5m2KSq6DZB
         Qoa6Zg2MCHMlbBcXnfAHgZhyXlPpez4AdfbJoty2CaosNbBLftsV1I7gB2cWFV/aYoKb
         CkVGMk41SUCk5mjtAHZsO0lydM57OuZYqFH2XYN0WqnV4Lh3SRHlKoqYQ0lKSTCGzjpQ
         MejhbV/eg/HyAlDCb9OxgW8yFgfiASV/IiYAVznPkCzXngrRpYNxJqxhVzPWEdyA/iZb
         wIfA==
X-Gm-Message-State: AGRZ1gLyZFBiKkHVdL16Zfz1j8eHbVLA3GVUoKG2dzZPPmB0Wjy1AFp6
        LoYxnB11xVEY8GYv9x7c5U5N/Q==
X-Google-Smtp-Source: AJdET5ea9ELhfBJqWhJkUUAKwWU/YwC7menbeVzkfZkFC/k14sI3PIEaIuMWudrTEbtlTcqkCzKccg==
X-Received: by 2002:a0c:bd9e:: with SMTP id n30mr123533qvg.196.1540251542838;
        Mon, 22 Oct 2018 16:39:02 -0700 (PDT)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-C3D.dyn6.twc.com. [2606:a000:1100:db::c3d])
        by smtp.gmail.com with ESMTPSA id t22-v6sm38965014qtt.1.2018.10.22.16.39.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Oct 2018 16:39:02 -0700 (PDT)
Message-ID: <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
From:   Jeff Layton <jlayton@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        willy@infradead.org
Cc:     Amir Goldstein <amir73il@gmail.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Date:   Mon, 22 Oct 2018 19:39:01 -0400
In-Reply-To: <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
         <20181019153018.32507-2-olga.kornievskaia@gmail.com>
         <20181020040530.GG32577@ZenIV.linux.org.uk>
         <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
         <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
         <20181022190620.GA8863@bombadil.infradead.org>
         <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-10-22 at 15:34 -0400, Olga Kornievskaia wrote:
> On Mon, Oct 22, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
> > 
> > On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> > > On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > > > Another thing is the commit message claims to:
> > > > "Allow copy_file_range to copy between different superblocks but only
> > > > of the same file system types"
> > > > 
> > > > But what the patch actually does is:
> > > > "Allow copy_file_range() syscall to copy between different filesystems
> > > > AND allow calling the filesystems' copy_file_range() method
> > > > between different superblocks but only of the same file system types"
> > > > 
> > > > It's probably OK and quite useful to do the former, but maybe man page
> > > > should be fixed to explicitly mention that the copy is expected to work
> > > > across filesystems since kernel version XXX (?)
> > > > 
> > > > If you don't wish to change cross filesystem type behavior and only
> > > > relax cross super block limitation, then you should replace the
> > > > same inode->i_sb check above with same inode->i_sb->s_type
> > > > check instead of doing the check only for calling the filesystem
> > > > copy_file_range() method.
> > > 
> > > Thank you for the feedback. In the next version, I will remove the
> > > check for the functions and instead check for the same file system
> > > types.
> > 
> > Jeff and I agree that this is the wrong way to go.  Instead, the
> > cross-device check should be in the individual instances, not the top
> > level code.
> 
> So remove the check all together for the VFS (that was my original
> patch to begin with (like #1 not this one). So am I missing the point
> again, I keep getting different corrections every time.

Sorry if I wasn't clear before:

Basically, I think Willy and I are both envisioning that some
copy_file_range implementations may eventually not be subject to the
limitations of the checks you're adding.

All of the current and currently proposed ones are however, so we need
these checks in place. We have two options. We can either do them
globally at the vfs layer or in the individual filesystem "drivers".

I argue that it's better to do it at the driver level, because if we
ever want to implement one that is not subject to these limitations,
you'll effectively have to push these checks down into the drivers
later.

That's where things become ugly for backports and such. You'll basically
be changing a subtle expectation in the driver interface, which could be
a source of bugs later. If we set the expectation now that the drivers
need to do this checking then we can (hopefully) ensure that they all do
before they're ever merged.
-- 
Jeff Layton <jlayton@redhat.com>

