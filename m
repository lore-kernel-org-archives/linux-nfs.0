Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF227C004D3
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 11:33:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5AFAB207DD
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 11:33:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DAXUzzLy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AFAB207DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726898AbeJXUA4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 16:00:56 -0400
Received: from mail-yw1-f66.google.com ([209.85.161.66]:40737 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726428AbeJXUA4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 16:00:56 -0400
Received: by mail-yw1-f66.google.com with SMTP id l79-v6so1906099ywc.7;
        Wed, 24 Oct 2018 04:33:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JeVVrCDWZ0t5dST26EslIAQmoAVpCawEY048n+9L26Q=;
        b=DAXUzzLyO3d9MB4nLFG9b5r4Oc6omWOdjVa39wdH5jbMD3QwyIQtG0lIDoSoHtlaAS
         Ka/WkAD9OHa0G86MCy81wo7VTjWm5paJXeSDiJHJxdDP79tuLNHzKpn6l1l7vZ8yEoxk
         XujpienoRlLRUBr5a/C8BTpSzjavG7rMuaGnG+PC6KiMPUQakBcFXUYIs99AZXFcdhgs
         PYH8iCNlaCzuvcdYTUE5XsR9UFcAZKuLtDvK9FZoJfLWLsxbvztVuXCA+HLpbgSH5ci7
         DjdE+fnZwICy4ipnXCi+4jMmCdgQNJJ4YOhss/6swJ6MTMW5vjThIImnxmqzte+ERXgu
         z7wA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JeVVrCDWZ0t5dST26EslIAQmoAVpCawEY048n+9L26Q=;
        b=X2/k4A9S39xPnthy2aDgYoVugotEkHV6Bct//u1T60+MaVT1itcrdvbzkB+uu1WwF4
         XjuSRVDzVAvvNEcFh+HwKNJtEcOGqn5R8y0TnfbZoC9XcEIQUlPDOpK5wIMckdrjgr6Z
         VfD+62xuaLAf7QbYYFzPggn5up7iNDGtDONEkvtnWvsbMHiNPU9OR2hnc5mWsiK7SYrJ
         459UPLBi/UwIA9CNpmrt/pNSP3NcESNGTjZBGah2aiyDIYySYzVBWjhg/4IZ1unN4iFB
         emGkl10Fhw2Z6s029iEtxutd6UKzUiGQg4+p1rLEQ9tPVJMMPAcZ0zZInsRy3OusP2op
         yQQA==
X-Gm-Message-State: AGRZ1gKSOOZL/kckf7WCl2X1YZxXd6bP8jmqKgTZc13Jup/80tRa5/GM
        RE+K/PHUHZnm1SMnpHyq+S6N2oBiFH5Vgj0/HMc=
X-Google-Smtp-Source: AJdET5eswIxyu5pDAJyiDFUcSEtx8geBWbLTduIFE7bsLQ86i+lzsdpeqzwt1YrLc2CVq0WwEPBrMftRBB3WZaaByq8=
X-Received: by 2002:a81:4d03:: with SMTP id a3-v6mr1671764ywb.211.1540380790222;
 Wed, 24 Oct 2018 04:33:10 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
 <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
 <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com> <20181023153941.GE20085@bombadil.infradead.org>
In-Reply-To: <20181023153941.GE20085@bombadil.infradead.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Wed, 24 Oct 2018 14:32:58 +0300
Message-ID: <CAOQ4uxj88JqhO0GF3Sim1kETPCBkZCVeAqGzWKVyCXkDwBLriw@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Matthew Wilcox <willy@infradead.org>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 6:39 PM Matthew Wilcox <willy@infradead.org> wrote:
>
[...]
> I've done some more research and found that while NFSv4.2 has its own
> representation of a copyable range of a file, iSCSI and SMB3 share the
> same ROD.  So it's not at all implausible that some other filesystem
> might also decide to use the same ROD, perhaps even NFS v4.3.
>
> It's clearly crazy to expect filesystem A to know about all the
> interpretations of filesystem B's file->private.  I'd expect us to add
> a function like:
>
> int vfs_get_rod(struct file *src, struct file_rod *rod);
>
> and then a filesystem's copy_file_range() would check to see if both
> src and dest referred to the same server, and if not call vfs_get_rod()
> to be able to send the ROD to the destination.
>

I am not saying cross filesystem type copy won't be possible.
I'm just saying we are going to get the API wrong anyway.
Surely, it is going to be either cifs or nfs42 that supports cross
fs copy first, not both at the same development cycle, so now
it seems flaky to use the out_file's copy_file_range() method.
You'd want to figure out which of the in/out fs supports cross fs
copy and call that method (not enough information).
I suspect we will need a new cross_copy_file_range() method.

And to answer Olga's question, yes, I do find cross fs copy with
do_splice_direct() beneficial.

Thanks,
Amir.
