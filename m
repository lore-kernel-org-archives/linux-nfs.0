Return-Path: <SRS0=m0hb=NO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB66C0044C
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 05:00:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 62A522081B
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 05:00:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fXdk4Mld"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62A522081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726649AbeKCOKy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 10:10:54 -0400
Received: from mail-pg1-f196.google.com ([209.85.215.196]:41027 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726200AbeKCOKy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2018 10:10:54 -0400
Received: by mail-pg1-f196.google.com with SMTP id k13so1831412pga.8
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 22:00:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O7fz8Hp2qUZHXy4d2o3PYOuOzFGbRkC9MluCsc79VxU=;
        b=fXdk4Mld4mDHAM8FPQKbkAX9weiruFMv7HfNvvadVsvIlRn47EVlChG/M4OxLQv2Gw
         +mdsutQQhacM40dOyYkRd2vpWlJTVUxPG5Mc0ct2rHOCgGim9+QzdFiDmAAxh6s9kDZJ
         1dJ8Y1L6kW5PbUZL5ECEpSP0i9BtUNT/5Ii4tCRDC7DQqbDaAgL9V1SHDUTf3K8Ad7p1
         9iaLBNpqobjhRtvAdc3oCrzjAHyGKz0l77uIIGmCr3zdf8C4CxdD7x4u2DPqqq/3tPgo
         VZw8IxILQkdfe/4cn21k+vw6s8dL7k6I+v0zpLeSsem+1edpzFb4nGR2Zgail9wH/Xl0
         3kMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=O7fz8Hp2qUZHXy4d2o3PYOuOzFGbRkC9MluCsc79VxU=;
        b=K6ry0Sm4nPwadU/flpbXyJLGAkXIBu0LHyry/33Y8ALzENfBNGURWw182103o/p13R
         qxijL066WmiMMf8mLqjgSNZzUMS7BGevzttSLs0i1c5S7oOdDMY9rQbzmPXXZxu6+wMa
         gWTuuMqZnq0DuDeqc6utU+bHm16Y54HX4fdQeA95Jgg6kZN8yRAlQS+LMK6RkDQ0xpTy
         WYPxiCUJihAp2tMkb/ymjalUaikzhfA0NW5mcNU/3LYYW3l+nRbv/rxTnPXpLdscwrX+
         UFIKu3KH8YMH8pKknzpyIvseg4EHlu6DVrQLf6FT0kBvFXB8r70v2TCdw1wDD1hQ+eTE
         R0dw==
X-Gm-Message-State: AGRZ1gJ2rHKFH5hQyp+nC7z4j9ytGtoIR7zQ42DQyZoHpSH4ILYt6a7q
        7IShAJKH0i+XgyXpt1FPNhTX0Lc5Anf5uPorFn4=
X-Google-Smtp-Source: AJdET5emb8Vc4uuRhAmdQkWYYMPuEEhY0YWGbilvs/qqC8Nh65pS71IvLECVmDbP3geLnk4EySMTHV+F3ANvndDqePY=
X-Received: by 2002:a62:c42:: with SMTP id u63-v6mr14412077pfi.43.1541221252990;
 Fri, 02 Nov 2018 22:00:52 -0700 (PDT)
MIME-Version: 1.0
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com> <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
 <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
In-Reply-To: <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
From:   Malahal Naineni <malahal@gmail.com>
Date:   Sat, 3 Nov 2018 10:30:41 +0530
Message-ID: <CAGD+tkyLAVn62Yb8SHig1rV8+3h7_fZzVaPuYA0ts=sHoYgSYw@mail.gmail.com>
Subject: Re: "(deleted)" directories
To:     trondmy@hammerspace.com
Cc:     bcodding@redhat.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> Why does your server need to have multiple filehandles refer to the same file

Trond, the first thing I want to understand is that this server's
multiple filehandles referring to the same file/directory is the
reason for the client's behavior described in this email. I am pretty
sure it is, but want a confirmation!

Ganesha by design uses one file handle on big endian systems and
another one on little endian systems. If a mixed cluster is going to
serve the same file system, then the same file will have at least two
different file handles. This is probably done to avoid needless
host2net and net2host integer conversions.

Also, how do servers deal with version changes in file handle? Looks
like live migrations will be broken when there is a file handle
version change?

Regards, Malahal.

On Sat, Nov 3, 2018 at 1:56 AM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
> > Ben, NFSv3 RFC1813.txt states: "If two file handles from the same
> > server are equal, they must refer to the same file, but if they  are
> > not equal, no conclusions can be drawn." Ganesha does return same
> > fileid here (inode).
> >
> > In NFSv4, they have introduced "unique_handles" attribute. I don't
> > see
> > Linux NFS client using this at all though.
>
> Why does your server need to have multiple filehandles refer to the
> same file, and why do you expect clients to support this?
>
> Yes, the spec allows it, but that's not a sufficient reason.
>
> >
> > Regards, Malahal.
> > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
> > bcodding@redhat.com> wrote:
> > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
> > >
> > > > Hi All, we are using NFS-Ganesha with Linux NFS clients. The
> > > > client's
> > > > shell reports the following. Based on lsof, the directory is
> > > > marked
> > > > deleted. "cd to ROOT and cd to the same home directory fixes the
> > > > issue. The client behaves as though the directory is deleted and
> > > > recreated! Our NFS-Ganesha server implementation uses multiple
> > > > file
> > > > handles that point to the same object. NFS spec says this should
> > > > be
> > > > fine, but Linux NFS seems to be broken in this regard. tcpdump
> > > > does
> > > > indicate file handle change (note that all file handles are
> > > > permanent,
> > > > meaning they are valid at the server any time) around this issue
> > > > time.
> > > >
> > > > "shell-init: error retrieving current directory: getcwd: cannot
> > > > access
> > > > parent directories: No such file or directory"
> > > > sh        112544            malahal  cwd       DIR
> > > > 0,67
> > > >      65536   45605209 /home/malahal (deleted)
> > > > (10.120.154.42:/nfs/malahal-export/)
> > > >
> > > > Function nfs_prime_dcache() seems to invalidate the dcache entry
> > > > if
> > > > nfs_same_file() returns false. nfs_same_file() does seem to
> > > > return
> > > > false with the following change, if I read it correctly, if there
> > > > is a
> > > > file handle change. Can this be the source of my issue? It seems
> > > > that
> > > > the client should do this only if the file handle is NOT valid
> > > > (e.g.
> > > > if it gets ESTALE), right?
> > > >
> > > > The following commit seems to assume that the objects are
> > > > different if
> > > > they have different file handles!
> > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
> > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
> > > > Date:   Thu Sep 22 13:38:52 2016 -0400
> > > >
> > > >     NFS: Fix inode corruption in nfs_prime_dcache()
> > >
> > > My understanding is that for NFSv3 we have to assume that distinct
> > > filehandles are distinct objects, but maybe I'm wrong about this.
> > >
> > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
> > > section 10.3.4
> > > to determine if the differing filehandles are the same object,
> > > specifically
> > > the fileid recommended attribute needs to be implemented.  Is
> > > Ganesha
> > > returning the same fileid for both filehandles?
> > >
> > > Ben
> --
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
>
>
