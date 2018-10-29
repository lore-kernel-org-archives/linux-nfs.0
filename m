Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 562D2C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:28:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F2B420657
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GPJfTjxI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F2B420657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726046AbeJ2XRb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 19:17:31 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:35232 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725989AbeJ2XRa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 19:17:30 -0400
Received: by mail-vs1-f67.google.com with SMTP id d62so3616907vsd.2;
        Mon, 29 Oct 2018 07:28:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9+7kR72Yq60tpcQTjHY7XP9SYCpj/0vei2ch1Swd8eI=;
        b=GPJfTjxInHuRJQCNuWY541pJXHAH9x95Lgzau0TPPjUG+p/yqf5rYgYVtMoTtdpa8S
         jSxEkVbKk3G8dx2kuMVVuj58RX2SfGrM3uycuzkER6WgG1vsRaaLg8bqjHPMOpgAes5H
         HYAl2Kux1MV/JFSm/yzUdJVOKFeanLdEhgamOA1Dm/MevuxVu2eBgA5WF9CKDcZAq/E8
         +QTxonahCBP8U5TvjtisqGSmT0roOuTZYJy9CRE1DHcKubeyZjDVRnAU4wzpOSvQV7gn
         zES8d8UbSMsKgMCoBZLAsCAFsuWGe85PgsHoMnBJKv4ZvDc5PrKJOrQxWX4pcic8Yk0N
         V4Yg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9+7kR72Yq60tpcQTjHY7XP9SYCpj/0vei2ch1Swd8eI=;
        b=kWipR66H971kHTCxnpDzFb1dt1Y7bjvqtLDQRz4iH96DmH9izRIMWdA763BABEaDdQ
         UW5yDvLjX4p+TbVwsYuxj6yZOk8lYGC8bSVTDXrLtaod8Avi3TcU9CIVeIjfJu5Egc2T
         iW5T3GRU6SbU67mdqQ0ymhoge/E4ba2iBylb8ugfy98D8ZRUm5CLmNq8bsWtvHLUpXCP
         aKZ1Mom+DIZIAQP/5ZB1RJ9aCNPjwdiCzh1w8Z4WKAUY2BzVMofpI9zvQoKRqSAb587n
         9N78Y1e81YZvPQXgWjOhGeKfVMzY+J35Q8vBx+32zswhL5UuVK/2BEMuKTP/qZSfEJES
         4+lg==
X-Gm-Message-State: AGRZ1gJPNB4FLONFz3iKRJC4K9791UfQwkQy1L50VyPprWgl8mkYNLJ3
        bK3xxYNoTbdhvc151mmmjHvHCGgvsdRHYyfK0E4=
X-Google-Smtp-Source: AJdET5csybF6QkYoKrQ5dy4VhbIOLtfcUpjqgLcvp9ZMaSLDHFqqjAFQeGH+OAU+MFgKD/ehID2Yzwkphobo1gNgbWU=
X-Received: by 2002:a67:4285:: with SMTP id p127mr3559710vsa.134.1540823316861;
 Mon, 29 Oct 2018 07:28:36 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-13-olga.kornievskaia@gmail.com> <7ef50e2c6b11ae80518db75efc35b2f96c9e4d32.camel@kernel.org>
 <20181027132624.GA25444@bombadil.infradead.org>
In-Reply-To: <20181027132624.GA25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 10:28:25 -0400
Message-ID: <CAN-5tyGjwn_xsVQWNtfUi=ZNd5OWJGeXPt1MEurQ1aSVC=PWaw@mail.gmail.com>
Subject: Re: [PATCH v4 11/11] NFS: replace cross device check in copy_file_range
To:     willy@infradead.org
Cc:     jlayton@kernel.org, trond.myklebust@hammerspace.com,
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

On Sat, Oct 27, 2018 at 9:26 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Sat, Oct 27, 2018 at 07:08:11AM -0400, Jeff Layton wrote:
> > >
> > > -   if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > > +   if (file_in->f_op != &nfs4_file_operations)
> > >             return -EXDEV;
> > > +   else {
> >
> > nit: you don't really need the "else" here since the previous block
> > returns
> >
> > > +           struct nfs_client *c_in =
> > > +                   (NFS_SERVER(file_inode(file_in)))->nfs_client;
> > > +           if (c_in->cl_minorversion < 2)
> > > +                   return -EXDEV;
> > > +   }
>
> Yeah, but if you don't have the else, then you need to declare the c_in
> at the beginning of the function instead of in the new block.  Mind you,
> if you do that then:
>
>         c_in = NFS_SERVER(file_inode(file_in))->nfs_client;
>
> fits on one line, so it does look a bit neater.

My thoughts for the "else" was to be able to get the nfs_client but
yes I could declare for the whole function and assign after the first
"if". I'll change it.
