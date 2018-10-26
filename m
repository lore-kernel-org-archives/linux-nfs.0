Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 948EFC6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:45:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2469120868
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:45:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="onz4B2nX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2469120868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727613AbeJZVWu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 17:22:50 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:39020 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727582AbeJZVWu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 17:22:50 -0400
Received: by mail-vs1-f67.google.com with SMTP id u21so611828vsl.6;
        Fri, 26 Oct 2018 05:45:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+oME05/7f1YhgjEjKFJiii0aT/C/1rXGrn11CBeuDOg=;
        b=onz4B2nX1Ff+B3a73v8J5TCKQ7xKpQLpMM//qNU9B+t/ChxC5G8j6sS1UfJw7kOUcF
         O2Xx0OVVq+/LAf9DuiZcJBXNNbg8zr6YGqXqikhN1JdUwkPMjNCwEG8DVJtR+oQvWJVr
         mhRpKhtMWAQ/M8P9Dfge9IfFctuNCQ6LRTcYaH4+Sdb1gmzpS3x9lC3N/L+Z0BZfNGBd
         LJhjBPHdNS0vfB6R2Kq4qzO5Rhqx3CTyTwpb11OY81XzmXToENAinF+yZqeMPDlI6X9h
         IbdONZLM3LmXEfVzrv1P1tNArcCosyCqrTGx9iawwxoGvESeL4tho61BYBHwFcJhftax
         +DVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+oME05/7f1YhgjEjKFJiii0aT/C/1rXGrn11CBeuDOg=;
        b=BoobXl6wACJmIuJOQWOZJRVfwAKbIFAKCaDGxoaE7gi3v1k6FnhDDDVTud+xNDYVcj
         rc6Uqob7dtrpFXBqIdZMRsIC8PoUFPwRy9NZ12O4OVV5JFGAXGfCCOWrm/hzy+VbbC6A
         JnO7kUy/fRALCM1toARhkCY8zTwQ9aFGcTaSauQ7LrMkRRu1RXL0TlX9PpSiPnr+eiRr
         NYI3nZ94Gk8L8U0SZeVZRfkHc9A+6ClRNOJVgSaPNBrwsRVP7j2Y5hQkFPV4DxJY0inG
         tpAYVuM1fY8BVu7KLZMWGmlAG0Tx+syu0eAmKKmuoR2VZY2o2Dh6H+mtThlIvJJLZ4V1
         SceQ==
X-Gm-Message-State: AGRZ1gJzP6E3CBfl+98G9mDDDEFU3/gYTnMmDttJTiE7J8Lhtb4PReUs
        9Fstlutknau1Lf29QUIX0jZxUqjO/qpK6AbMonU=
X-Google-Smtp-Source: AJdET5fo0Na8DtZsGxH91rsLIdwX1wbw2mAOMmgyWagDFgu10tMQ56ljvhIVtdwxDySz0VFYLwQbtWOqKePikF9kAhQ=
X-Received: by 2002:a67:f441:: with SMTP id r1mr1437564vsn.164.1540557950828;
 Fri, 26 Oct 2018 05:45:50 -0700 (PDT)
MIME-Version: 1.0
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
 <20181025215147.36248-13-olga.kornievskaia@gmail.com> <20181025222754.GN25444@bombadil.infradead.org>
In-Reply-To: <20181025222754.GN25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 26 Oct 2018 08:45:38 -0400
Message-ID: <CAN-5tyEtHdZZ6Rvs+DZWbU9O5MU3hVwvSCsUFx+fjrY7AZ1JMA@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] NFS replace cross device with cross filesystem
 check in copy_file_range
To:     willy@infradead.org
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 6:27 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Oct 25, 2018 at 05:51:47PM -0400, Olga Kornievskaia wrote:
> > -     if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > +     if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
>
> Isn't it simpler to do:
>
>         if (file_in->f_inode->i_sb->s_type != &nfs4_fs_type)

I don't believe that's sufficient. What if "in"  fs was NFS and "out"
fs was CIFS?

> But now I've done some grepping, and I wonder whether it's possible
> / desirable to also copy between inodes on a nfs4_remote_fs_type,
> nfs4_remote_referral_fs_type, nfs4_referral_fs_type or nfs4_xdev_fs_type.
> I haven't kept up with NFS development for a while, so maybe none of
> those are possible.

Thank you for pointing it out. Grepping thru the code, don't believe
the last one is used but for the migration and replication types, I
don't know if there are any caveats that would preclude support for
copy offload I'll check with Chuck Lever. Then the check should be
that "in" and "out" are any of the 4 NFS types.
