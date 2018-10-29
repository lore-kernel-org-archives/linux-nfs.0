Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C6DEC2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 16:09:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E1AD2084A
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 16:09:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pKkMAgGn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E1AD2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727745AbeJ3A7B (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 20:59:01 -0400
Received: from mail-vk1-f194.google.com ([209.85.221.194]:36339 "EHLO
        mail-vk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727565AbeJ3A7B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 20:59:01 -0400
Received: by mail-vk1-f194.google.com with SMTP id d141so2195033vke.3;
        Mon, 29 Oct 2018 09:09:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ms3Gdc7Ag8dICd2wfNCY3Nx4WzyxNNZw125Qy1irBYQ=;
        b=pKkMAgGnKQLj41eiWTF4WVFlSlaIkyyFW+hzCtERgy7PGUF5jSRIVMvZ75J7uAJyg+
         y+Ll5z0C2xeVK6E+ktpMy/zr4wsSER8wxcFB4V4M+zld7nYe8nTXHe3nNKcKH5VlQVjf
         mkeKkC0M5lxpa0ucAZjHQ5bg7jtuVx1GG2xVDdTmbmUDIsPNiYZot4BqcWk+grOsbASm
         LeEOMMLLoWsSjjStMk3TI7UIJrT8A2jNfbSesujbiNQ2wYizC7Hgcwbf6Vd6kvGaPtNR
         ZZoVLujXQFt4PzdNzJd5cifexf1kylLlZE4iMWWHz7U+fO/4o7I2GfhhpPBBuf+WZ8Ox
         kIwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Ms3Gdc7Ag8dICd2wfNCY3Nx4WzyxNNZw125Qy1irBYQ=;
        b=KKMPBqQRDvoiFTk9v6iPbaUTCO25Bjde4rK6t4/9bPZXyV8dzBOdVqhWxqrEn+hVfr
         jRJszvbNhkeWurvTpO9nbr46oSALYQjG/CyDZBjphnedl1Rl4t7sG1IIpdobXjlHuXti
         tXzOxVB6Cfhw+vlg3AN7+OCdI62K9LKalYM604IQYNJUxLXU1F3ev7G2AQSeb96M8CFd
         dZqzH2Q3DANaXIEQ5xNUfP+Bas+JNwJYYzeB/NSvWvx06cDgFPyKcsod+gakIR0Xhqrs
         wIE58NY+DQUkcpK+nJsIDIJhIwxboEb0JyP9rm28AbWy7QZfvDwpVrajnyk/tyvkJCZK
         Xwiw==
X-Gm-Message-State: AGRZ1gJPhZLsuU/6AWAuj50U7Z7P0kIwsWKyk8I7thH7VyWHNJmDlhJw
        MHe7kTN8zzCI6t6po/Lr+bLqkJNmP+peZwfJRaw=
X-Google-Smtp-Source: AJdET5efp8ohZ+6cOP/0AFJQtx5fsgpdC92xGpNrZFkMZIlQnqTpxc9HhU7ZADsmsC6ZozYmheaLJWyzwktjSib603M=
X-Received: by 2002:a1f:ac4:: with SMTP id 187mr3274189vkk.31.1540829385014;
 Mon, 29 Oct 2018 09:09:45 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com> <20181026212631.GY25444@bombadil.infradead.org>
In-Reply-To: <20181026212631.GY25444@bombadil.infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 12:09:32 -0400
Message-ID: <CAN-5tyF=sSTx5JquKJRwNUP4r1+GBJuJUcW4xz4GrDXMjVk=Gw@mail.gmail.com>
Subject: Re: [PATCH v4 02/11] VFS: copy_file_range check validity of input
 source offset
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

On Fri, Oct 26, 2018 at 5:26 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> > +++ b/fs/read_write.c
> > @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >               }
> >       }
> >
> > +     if (pos_in >= i_size_read(inode_in))
> > +             return -EINVAL;
> > +
> >       if (file_out->f_op->copy_file_range) {
> >               ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
> >                                                     pos_out, len, flags);
>
> Is this the right place to check this?  Surely we should be checking for
> this before calling clone_file_range()?

Ops, indeed this is the wrong place. If I were to keep this check here
then I need to move it where it was originally located. However, right
now I'm included to not do the check in VFS at all and move it to NFS.
