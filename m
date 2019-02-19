Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77050C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 02:09:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 378A121773
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 02:09:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fMyso69k"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726260AbfBSCJj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 21:09:39 -0500
Received: from mail-ed1-f44.google.com ([209.85.208.44]:34180 "EHLO
        mail-ed1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726225AbfBSCJj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 21:09:39 -0500
Received: by mail-ed1-f44.google.com with SMTP id b3so15456354ede.1
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 18:09:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=tSlZ1opQXdL7qPnXXGV+oi11COU7cogrhVlhiWXiQdU=;
        b=fMyso69ke4DFibWM6PDqmmFyVUi7wEBEyxSrHnQdef4pvvgygIlf+4exXe1vi+eYBo
         bjbs9agmaqjBeHo3CgEldIj0hzXAr7oXf4gIciaVD8dinKXWHy4f6Ma5NQPLym2qwLgU
         +HXBgq3GTW5WbufTp41BbeE1SPxoAD9q45ZQkfTEkLj3M6GD97ZRI0Rl6NSw2Xv25ohz
         sKe76WJ0IRL6R3TIawaNsbsPMY4NCG72o0RqF76mrT9pFabfYLml2rbrtLk4ezAkEIZs
         QMeiZDR1PwGyzmlChX+C4ML3sdhuYiVeOm0tidpkIgj2nTH0OaXso+bm1AkqJryovcLj
         Iicw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=tSlZ1opQXdL7qPnXXGV+oi11COU7cogrhVlhiWXiQdU=;
        b=M6a55Sr/QSyETTuQcH6aauO9e2bps538Mj3TK8PGkgzXe0Ob4esQI1AbJi5dc2p/yk
         iMl/bPIy7IMF6qmvgaQGEC9dI2ImE+vFnghrvlmwjiv0ONdPCiThtWgPGtyfW8cOmfMj
         4v6gsAMIXJVlKsuFQ4diCTy1f679upMZyPWY/BSbT3tJg+xirtf+qpL9EHIZ64QN7eFu
         naV2iOcjlch+gfAc12ICubEO2MkFvqcHRXkPPfU+kYj/hkCrhzHSvjjL9k5EYW92REwA
         IyrDy+7ro59HHvLGnDWBEnRl8+ODeRuuYCaIZX3tQ30DeJ4G9s77KrUmHPYHVBZy3BKI
         /9qQ==
X-Gm-Message-State: AHQUAuYmvsd549rsaXCkWsikq1bcgomF80QnxX5Unk0hqRGnzMRoRajx
        2A7IiwmICB7D+q/vnQsK929R9G+PhUG8cWzaZqDlEkWd
X-Google-Smtp-Source: AHgI3Ibsw3OxljJBQPYHBy8eIB37l5BlAyLPb8ug9RxqaE0O/HY+H9HDNbKM2AP/3fCdXq8cq0/YmFBS7SBsymp/I98=
X-Received: by 2002:a17:906:1191:: with SMTP id n17mr18702653eja.47.1550542177066;
 Mon, 18 Feb 2019 18:09:37 -0800 (PST)
MIME-Version: 1.0
References: <CANidX5RGLuvdS82TpxuagUsA4DmUochDv2AwX7rwHdD-q+Khbg@mail.gmail.com>
 <20190218202146.GB5879@fieldses.org>
In-Reply-To: <20190218202146.GB5879@fieldses.org>
From:   Gefei Li <gefeili.2013@gmail.com>
Date:   Tue, 19 Feb 2019 10:09:25 +0800
Message-ID: <CANidX5RjDwJ=yN=aG_D+pQ4fzJ-gXrdqbmwin9eOkyerCU6QRA@mail.gmail.com>
Subject: Re: linux NFS client lock file cannot get a expected response
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks a lot for your reply! I tried to capture and analyse the
network packets with wireshark and find that a NFS4ERR_LOCKED(10012)
replied in my experiment 2.2(open with O_SYNC and write) Write
response. Does this mean that my NFS server uses mandatory locking?

But something unexpected is that an EAGAIN(Resource temporarily
unavailable) returned in user space, I think an EACCES/EIO is better
for locked situations, what's your idea about this?

>> You're checking the file content on the server somehow?
I close my lock program in my first shell, and check from both
server-side(use notepad to view the file) and client-side(cat/vim to
view the file), the file content remained unchanged.

Best Regards,
Gefei

On Tue, Feb 19, 2019 at 4:22 AM J. Bruce Fields <bfields@fieldses.org> wrot=
e:
>
> On Mon, Feb 18, 2019 at 05:11:47PM +0800, Gefei Li wrote:
> > I am recently testing linux nfs lock with NFS share from a WinServer
> > 2016. I tried to write a file which has already been locked with fcntl
> > exclusively, but the response of `write` syscall is neither
> > `Permission denied`, nor successfully written with file content
> > changed. Here is several experiments I did:
> >
> > The first shell runs c program, calling `fcntl` to lock file
> > exclusively =E2=80=9Cfcntl(fd, F_SETLKW, &fl)=E2=80=9D
> >
> > 2.1 The second shell tried to open with flag O_RDWR, and write a
> > buffer to the same file, write returned the correct bytes written, but
> > the file content remained unchanged.
>
> You're checking the file content on the server somehow?
>
> The client's caching the write--it returns success to the application
> and then sends the actual write to the server later.  Anything else will
> hurt performance of a lot of applications.
>
> > 2.2 The second shell tried to open with flag O_RDWR|O_SYNC, write the
> > same buffer to the same file, write operation returned EAGAIN
> > 2.3 The same operation on ext4 file system gives me a expected
> > behavior the same as advisory lock expressed, successfully written
> > with file content changed.
> >
> > I reviewed NFS 4.1 protocol(RFC 5661 page 185), the nfs server can
> > determine whether byte range lock can be either mandatory or advisory,
> > but I think 2.1 and 2.2 gives me some unexpected behavior as these
> > two.. What=E2=80=99s your idea about this? Can you give me some tips to=
 work
> > this out?
>
> There's also section 10.3.3, but I never understood how that was really
> supposed to work.  It recommends the client turn off caching when
> mandatory locking is in effect--but the only way it gives the client
> that mandatory locking is in effect is by seeing an ERR_LOCKED reply to
> a READ or WRITE, and by that point it's too late.
>
> Anyway, as far as I can tell the results you report are what's expected.
>
> --b.
>
> > Looking forward for your reply. Thanks in advance!
> >
> > BTW, my linux kernel version is 4.15.0, linux release: ubuntu 16.04
> > from Azure marketplace, my nfs-common version is
> > "nfs-common/xenial-updates,now 1:1.2.8-9ubuntu12.1 amd64" from ubuntu
> > apt repo.
> >
> > Thanks,
> > Gefei
