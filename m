Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56EBEC65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 03:47:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EFC9620873
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 03:47:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gCXhz+qc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC9620873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726453AbeLMDrn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 22:47:43 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:37905 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726437AbeLMDrn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 22:47:43 -0500
Received: by mail-oi1-f193.google.com with SMTP id a77so546834oii.5
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 19:47:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qStkbhlGuo83rOV4EdlUPFAFkjZ5rh6LH0v0+bsJZ+M=;
        b=gCXhz+qcksiZDzXJZzUYxyIG6ZCOkpGTeB/Yn7cS2U6/HF5F/VYvhrKrnZK5G2El18
         ujGOhKXifKCghNCPhEQCglj0B38TdVNV90GgFVYt5yR6OCSrn3JzudtTpTDZC6s/S3Rh
         YTccChHXkeEO/LPK6KXmwNGFACwGPv81Y1/l8geEyLGGUNCfBl86zzijBW8sHcumNUZp
         dA1UpmEY6Vtd0dvtwDhlbY34pj4410eORjd8uVDLR5VkOTChRWQtva+QLKVdRCc8wtSG
         YlShIouUH4SVfaAZ0TFKnZ5glR0648aAy/A0h89cTUswxZ9XZ9TvKzHL6Af/bcf5pPX6
         h1Yg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qStkbhlGuo83rOV4EdlUPFAFkjZ5rh6LH0v0+bsJZ+M=;
        b=hjKn7YDPKDe643xK60WpmSjit3Th8QqnwCEGxr5/L00a9uheebodFORT8mMK6sYcSc
         3x9R3GbyxCG4lL0vLfHEzP3hyOdl8K63L5UJ9evfyfjjg5fajtyjjUILP06U3IruV5Xp
         RSrx2mROUCWmFDkrQ6D8LsY6dhCkqsGezB+lGao5gw39cjx2voWugV/U4lgjyX2e8+RY
         5LQTLYwJthJIcvts0jimqpTJ43F+GDYbZD+Y6u1298wu5ALk0rCRjwvFbxVPVy7Gj3bt
         OfgvLxc6eb/WYM2q3lYqF6HisfAVFuAAfmL1votPuLEx9HyzB8n+BiNPb83bs8uRGU4Y
         0G/A==
X-Gm-Message-State: AA+aEWb8qqJBbYNdrQOjKli1HDIhhqKG+hXvrG9YiNtjVJPJWpHyjtvU
        pgnqjBO+WBGN1DA4YjpZ552cxdSn9ZCHynGViv0=
X-Google-Smtp-Source: AFSGD/U6HqldxJ8AxWUzERku5TZ7o4GeB/WAHQDGs2ZEibqBJa9TWFYSN0QRNwO8oBdDhiLqHuE9fn+YDgcbaUZm0xA=
X-Received: by 2002:aca:ad14:: with SMTP id w20mr1117798oie.3.1544672862344;
 Wed, 12 Dec 2018 19:47:42 -0800 (PST)
MIME-Version: 1.0
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
 <878t0uuzxv.fsf@notabene.neil.brown.name>
In-Reply-To: <878t0uuzxv.fsf@notabene.neil.brown.name>
From:   Ashish Sangwan <ashishsangwan2@gmail.com>
Date:   Thu, 13 Dec 2018 09:17:31 +0530
Message-ID: <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
To:     neilb@suse.com
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks for the clarification!

On Thu, 13 Dec 2018, 4:15 am NeilBrown <neilb@suse.com wrote:
>
> On Thu, Dec 13 2018, Ashish Sangwan wrote:
>
> > Hi,
> >
> > Our NFS filer can sometimes return same inode number for different directories.
>
> Why?
The NFS fileserver is handling file systems over different nodes at
the same time.
To the client however, we want to present with a single pseudo fsid
(sent as part of the getattr) so that submounts can be avoided.
We have assigned unique numbers to identify different file systems and
we append those numbers to the actual on-disk inode numbers to avoid
the collision.  But in some rare cases there is not enough free bits
in the inode to accommodate the unique filesystem identifier.

>
> > For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
> > and dir4 might end up returning the same inode number to the client.
> > Though it can never happen that inode numbers will be same for two
> > directories and also there parent is same. Can linux client handle
> > this case? What issues it can cause?
>
> As long as the file handles are different, the Linux client won't really
> notice.
A naive question here. This should also not cause any issue in the VFS layer?

> Problems might occur with applications which check inode numbers.
> I don't know of any that would be confused by directories having the
> same inode number, but that doesn't mean there aren't any.
>
> > https://lkml.org/lkml/2006/10/2/346
>
> This is ancient!  It is mostly about the NFS server, not the client.
> Filesystems that NFSd is exporting need to be careful to provide unique
> file handles.
>
> > I stumbled upon this thread where it is written that nfs client can
> > handle this but userspace will see inode collisions. Given that this
> > will happen only for directories, userspace utils logic might not get
> > affected from this as hardlinks on directories are not possible. But
> > the thread is really old. Wanted to confirm if this holds true even
> > now.
>
> I don't think anything important has changed.  The server must return
> unquie filehandles.  It should return unique inode numbers.  User-space
> may or may not get confused if it doesn't.
Understood that this has to be fixed ultimately. Just wanted to have
an idea regarding the severity of the issue.
>
> NeilBrown
