Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E25DC65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 20:22:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC3C720811
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 20:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HqLEkXwh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC3C720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726440AbeLLUWh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 15:22:37 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:38215 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726247AbeLLUWg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 15:22:36 -0500
Received: by mail-vs1-f68.google.com with SMTP id x64so11877196vsa.5;
        Wed, 12 Dec 2018 12:22:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=n6fmSkrQgF2z0deKC1H/kEESg9FcPjcsNJOq/TWN04U=;
        b=HqLEkXwhbfHbxLFite/XyY3nvqWfRZZ/zb6/7p0R2UEDR/gQWmD4TB3tzvG+6mBD8m
         yY1E226+CL/4CdyBCvCooIe39fw1DJAYVoLafG4FeqnLyjZFe1vBghWUp713E0UxpKLH
         P2YxMtMeRzgMNj6Z8VG440yZvNXg+erpBE3XH8Kwam1Q7jUFoWYoO04VJTf0FMrqc/yL
         gG0IsGg5o4tlEfCp70aRm4tvnTP10hjhZgS7n7G83dY1d+tBhD0O5EsecjD1k/+ZcYUQ
         aYtgzKkvP3LswTgvXx3p1hYXgC2gOnJv36ISDCdlop/VA1Vr7WmQX1Speqdx7QIuH8TR
         iirw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=n6fmSkrQgF2z0deKC1H/kEESg9FcPjcsNJOq/TWN04U=;
        b=hilY0HiLBt9NTfqTHXKXF/sp7f+lH4DITlOI6EdlO1rCq3EH+/uB8FiKRaFjTgS8I3
         bMuuqaj1FbcGrw8W5xXFgZm/3YJTrr51fYsdOopUzv/Zd3lT2PK73bBuN7sfY8EUEnge
         Ve6hvMQuN4YObABKgOUIS10/ztNQRvS5PbFTRFOsSNwN9Gvt5TWkMeio6QmIOf21VhCD
         RFl2h909Qz8J0nQ7gPWE3jI8ARgy+dw6+0N2L2plpSbFlsEGvOrV5JRWDATB6hBvlrPj
         aVRWYSbSxxJGb2P0c31AFczKjBpzfNEmdL0NbPxE1LO8I5CNOAXDGOIs+/fvftBeBmKh
         i7bw==
X-Gm-Message-State: AA+aEWZ0kUdoLxCn6EtRhN1avrGAvpeWXNliZCX9hziN6rCzwRp87CDQ
        38B1Zlebg04pShpvFveZ7CsbzhuC2u0OmJhhODKhzg==
X-Google-Smtp-Source: AFSGD/VrtHRpJ+QEEFGkRoLnL4tSuKW95vNWn3UpIcbpL01g/OksZw85nKaUA7QZw25AYL9BdLcnoCwzMawxC5FNbkQ=
X-Received: by 2002:a67:4285:: with SMTP id p127mr9854598vsa.134.1544646154965;
 Wed, 12 Dec 2018 12:22:34 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-5-david@fromorbit.com>
 <87a7lbrng4.fsf@suse.com> <CAN-5tyHNGtLxeFyEO6qX_+8=K4tpkgYjB11OkfCTdWfokfAyEg@mail.gmail.com>
 <20181212194258.GK6830@bombadil.infradead.org>
In-Reply-To: <20181212194258.GK6830@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 12 Dec 2018 15:22:23 -0500
Message-ID: <CAN-5tyGmdrbbiej_mMosYKrCzOEuKMKJALfOJxvbBqHwZFiUOw@mail.gmail.com>
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
To:     willy@infradead.org
Cc:     lhenriques@suse.com, david@fromorbit.com,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 12, 2018 at 2:43 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Dec 12, 2018 at 01:55:28PM -0500, Olga Kornievskaia wrote:
> > On Wed, Dec 12, 2018 at 6:31 AM Luis Henriques <lhenriques@suse.com> wrote:
> > > I was wondering if, with the above check, it would make sense to also
> > > have an extra patch changing some filesystems (ceph, nfs and cifs) to
> > > simply return -EOPNOTSUPP (instead of -EINVAL) when inode_in ==
> > > inode_out.  Something like the diff below (not tested!).
>
> > > +++ b/fs/nfs/nfs4file.c
> > > @@ -136,7 +136,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> > >         ssize_t ret;
> > >
> > >         if (file_inode(file_in) == file_inode(file_out))
> > > -               return -EINVAL;
> > > +               return -EOPNOTSUPP;
> >
> > Please don't change the NFS bits. This is against the NFS
> > specifications. RFC 7862 15.2.3
> >
> > (snippet)
> > SAVED_FH and CURRENT_FH must be different files.  If SAVED_FH and
> >    CURRENT_FH refer to the same file, the operation MUST fail with
> >    NFS4ERR_INVAL.
>
> I don't see how that applies.  That refers to a requirement _in the
> protocol_ that determines what the server MUST do if the client sends
> it two FHs which refer to the same file.
>
> What we're talking about here is how a Linux filesystem behaves when
> receiving a copy_file_range() referring to the same file.  As long as
> the Linux filesystem doesn't react by sending out one of these invalid
> protocol messages, I don't see the problem.

Ok then this should be changed to call generic_copy_file_range() not
returning the EOPNOTSUPP since there is no longer fallback in vfs to
call the generic_copy_file_range() and in turn responsibility of each
file system.
