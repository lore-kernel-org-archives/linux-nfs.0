Return-Path: <SRS0=fIcc=S6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28331C43218
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 22:00:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E4CD220656
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 22:00:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WUn9R0mz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726478AbfD1WAq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Apr 2019 18:00:46 -0400
Received: from mail-yw1-f47.google.com ([209.85.161.47]:42370 "EHLO
        mail-yw1-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726435AbfD1WAp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Apr 2019 18:00:45 -0400
Received: by mail-yw1-f47.google.com with SMTP id y131so3053856ywa.9;
        Sun, 28 Apr 2019 15:00:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UowcWs8y0NGAO7QnT930/knM1MIEOfa1b7WqTNQHJco=;
        b=WUn9R0mzrF8SlWRavwbBrTw9rACo0epTaN8VpSiq10DdpdfcuH3qcWW1QKXaWWgh4P
         iDLBOlhPFHz+WkgAZ4eAR8OgotEOXRwBTG3QUSvHFz/c7etoJVTTIvv8haRg7CGX0Nd7
         xO0Q5FIulDdq7aFGs+o/PCRqO/037GhmOaIFLbnBZVVP/SA46jCOTYBaFnmCA6xQqJef
         x7ouR5i+40BHjEPipkZ/g+ZQCjSCmo9sZxRyl1caADHq/ia3qDQDIT7KcRjSzeWONmav
         m88V/eCmCUVUJ8Uv6TbkjfsnLKFPW6o50WimbloVPsHXVmE9jG8CNy64bacKfO+in7tv
         P1lQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=UowcWs8y0NGAO7QnT930/knM1MIEOfa1b7WqTNQHJco=;
        b=deC0i3z9NgGkqAhgHH7ANcy0qffuOkYf9Xnzmyc8CAo/aZ3IKBB9mD7bNYatXVcfc4
         ElMqvNsFoPXU9U+5mLo41Baw5GuJwVeDAN07Ikdxq641yw9xkJ9TIyF5ph/TgiIxbhxF
         LODXq+XswfeI6+BK4bdGsgxeFuIWpX9H6A9WxuFiL0U6AjTk27ufK2rdFc+2c7QzS2wJ
         J+d+s6WjLDGQUiJ3T0IMaPGNuaEe8Aqj66yF/Fj8qNv9YskdnG8JLfosCSNS6/Z81LYo
         pYN5o0tDMDdrM8qztqliP5hRgg4lqLGiddAPRTGzRBM+XC1qRjQ6S7Yg+rIp7qEzKxHi
         WFzA==
X-Gm-Message-State: APjAAAXZfC9huTwhr5p1mYP5kCVqCSvB6RUI+vjRN3vQ3XjNoHGsqO4L
        ORqLNdGToHxwBy7oeLNrOi0VSXm2RgPWjcfddR+ptLLh
X-Google-Smtp-Source: APXvYqxS/M/9nqsjsuAB3ssK0QulC5IuiTmzjAFxYi1glexGKAOy84GfxrWynrlQlL2q8s2rukCTOqiYnwNr5yhZfdY=
X-Received: by 2002:a0d:ff82:: with SMTP id p124mr50257703ywf.409.1556488844487;
 Sun, 28 Apr 2019 15:00:44 -0700 (PDT)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <930108f76b89c93b2f1847003d9e060f09ba1a17.camel@kernel.org>
 <CAOQ4uxgQsRaEOxz1aYzP1_1fzRpQbOm2-wuzG=ABAphPB=7Mxg@mail.gmail.com>
 <20190426140023.GB25827@fieldses.org> <CAOQ4uxhuxoEsoBbvenJ8eLGstPc4AH-msrxDC-tBFRhvDxRSNg@mail.gmail.com>
 <20190426145006.GD25827@fieldses.org> <e69d149c80187b84833fec369ad8a51247871f26.camel@kernel.org>
 <CAOQ4uxjt+MkufaJWoqWSYZbejWa1nJEe8YYRroEBSb1jHjzkwQ@mail.gmail.com>
 <8504a05f2b0462986b3a323aec83a5b97aae0a03.camel@kernel.org>
 <CAOQ4uxi6fQdp_RQKHp-i6Q-m-G1+384_DafF3QzYcUq4guLd6w@mail.gmail.com> <1d5265510116ece75d6eb7af6314e6709e551c6e.camel@hammerspace.com>
In-Reply-To: <1d5265510116ece75d6eb7af6314e6709e551c6e.camel@hammerspace.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Sun, 28 Apr 2019 18:00:32 -0400
Message-ID: <CAOQ4uxjUBRt99efZMY8EV6SAH+9eyf6t82uQuKWHQ56yjpjqMw@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "jlayton@kernel.org" <jlayton@kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Volker.Lendecke@sernet.de" <Volker.Lendecke@sernet.de>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "pshilov@microsoft.com" <pshilov@microsoft.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Apr 28, 2019 at 11:06 AM Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Sun, 2019-04-28 at 09:45 -0400, Amir Goldstein wrote:
> > On Sun, Apr 28, 2019 at 8:09 AM Jeff Layton <jlayton@kernel.org>
> > wrote:
> > > On Sat, 2019-04-27 at 16:16 -0400, Amir Goldstein wrote:
> > > > [adding back samba/nfs and fsdevel]
> > > >
> > >
> > > cc'ing Pavel too -- he did a bunch of work in this area a few years
> > > ago.
> > >
> > > > On Fri, Apr 26, 2019 at 6:22 PM Jeff Layton <jlayton@kernel.org>
> > > > wrote:
> > > > > On Fri, 2019-04-26 at 10:50 -0400, J. Bruce Fields wrote:
> > > > > > On Fri, Apr 26, 2019 at 04:11:00PM +0200, Amir Goldstein
> > > > > > wrote:
> > > > > > > On Fri, Apr 26, 2019, 4:00 PM J. Bruce Fields <
> > > > > > > bfields@fieldses.org> wrote:
> > > > > > >
> > > > > That said, we could also look at a vfs-level mount option that
> > > > > would
> > > > > make the kernel enforce these for any opener. That could also
> > > > > be useful,
> > > > > and shouldn't be too hard to implement. Maybe even make it a
> > > > > vfsmount-
> > > > > level option (like -o ro is).
> > > > >
> > > >
> > > > Yeh, I am humbly going to leave this struggle to someone else.
> > > > Not important enough IMO and completely independent effort to the
> > > > advisory atomic open&lock API.
> > >
> > > Having the kernel allow setting deny modes on any open call is a
> > > non-
> > > starter, for the reasons Bruce outlined earlier. This _must_ be
> > > restricted in some fashion or we'll be opening up a ginormous DoS
> > > mechanism.
> > >
> > > My proposal was to make this only be enforced by applications that
> > > explicitly opt-in by setting O_SH*/O_EX* flags. It wouldn't be too
> > > difficult to also allow them to be enforced on a per-fs basis via
> > > mount
> > > option or something. Maybe we could expand the meaning of '-o mand'
> > > ?
> > >
> > > How would you propose that we restrict this?
> > >
> >
> > Our communication channel is broken.
> > I did not intend to propose any implicit locking.
> > If samba and nfsd can opt-in with O_SHARE flags, I do not
> > understand why a mount option is helpful for the cause of
> > samba/nfsd interop.
> >
> > If someone else is interested in samba/local interop than
> > yes, a mount option like suggested by Pavel could be a good option,
> > but it is an orthogonal effort IMO.
>
> If an NFS client 'opts in' to set share deny, then that still makes it
> a non-optional lock for the other NFS clients, because all ordinary
> open() calls will be gated by the server whether or not their
> application specifies the O_SHARE flag. There is no flag in the NFS
> protocol that could tell the server to ignore deny modes.
>
> IOW: it would suffice for 1 client to use O_SHARE|O_DENY* to opt all
> the other clients in.
>

Sorry for being thick, I don't understand if we are in agreement or not.

My understanding is that the network file server implementations
(i.e. samba, knfds, Ganesha) will always use share/deny modes.
So for example nfs v3 opens will always use O_DENY_NONE
in order to have correct interop with samba and nfs v4.

If I am misunderstanding something, please enlighten me.
If there is a reason why mount option is needed for the sole purpose
of interop between network filesystem servers, please enlighten me.

Thanks,
Amir.
