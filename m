Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D444C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 15:54:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2334C20657
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 15:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ju1JqxuQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2334C20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727824AbeKCBCV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 21:02:21 -0400
Received: from mail-pg1-f169.google.com ([209.85.215.169]:38886 "EHLO
        mail-pg1-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727820AbeKCBCV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 21:02:21 -0400
Received: by mail-pg1-f169.google.com with SMTP id f8-v6so1166508pgq.5
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 08:54:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RuTjqpDH5SgWCsiGZGBvnYwrCQr7UlgTz2Ux/gaM5tQ=;
        b=ju1JqxuQeQkJziUqhPp9Jtm8YhxL3g8BjgHgtLaoLz7ZCjLKURJc9lymgqBUAedI9y
         v9tpwLp4SvRwq/j8Fa3+T+Y3lz7ydukV7kX2WnKDCON/LKvo549KC0BWVkr1iXLwjdlf
         wO31TLewgxKJwImEO/wjFBBamPWKnpfuzYeOctwisGTXpq6Ze5jlY9/pFFkPL+Cr9nD6
         p+V6p+uIq1oN04WgZrOXJtWmCin9Ou/KAloyLjFNEmFUkVH1clnNB2ogTa6Q4ZruTqBf
         dqw/+IfivbbJcPGMmdsT3jhrGVWtutxwp1ZptCT0Fzhu4e3YfisLlodbRWZWAIH+5Dmc
         o4jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RuTjqpDH5SgWCsiGZGBvnYwrCQr7UlgTz2Ux/gaM5tQ=;
        b=hlIOLNg510Q9v0FADSRFFq2wcBbwTevnmW+FE8PaQ0ODoYaE0nta8MSg4IMjyzpNMh
         FxN4E8fD/fBpCrpQcdgx3vdgVirVqwKKG48LpUotWu9gr2F4hczINMQ0z5gBJ+gFT3ma
         MUlORg+TgyW7kLPbGvyvjBxrHzC+4+nRk9qb0tesVtmHnj6l9AFIGlpeS8Jz4yCD5I8m
         VgFgZeV6cWrRdvnfiESw+k2s9HOZH8m4Ny11SHN1GE0eY/KD1Mmw91ZHoAt72rd0teSd
         bt1eUWUyOgzuo14gzO7/bTVW0QJDbHbtBsUC2lsNXBSB4hwh6dNaWKnx6xicAzGahne5
         gi4Q==
X-Gm-Message-State: AGRZ1gIR1rBOskhYJZuN03fzU58+1oCZy+jvUAes1KSK2dhEYhrQCpFa
        g+GlIWvzJojEr5wbHG44XHF6vi/Pazr+csuWtyiPvUBx
X-Google-Smtp-Source: AJdET5c2N87hmAggV8FaVN2ztQx4AR/OdWkIKT79i9QLi6/QYj2jfMtler3ALOieVM9m7T/lv97aN7hD/xkt+iyXm9Q=
X-Received: by 2002:a63:b5b:: with SMTP id a27-v6mr10649159pgl.97.1541174087747;
 Fri, 02 Nov 2018 08:54:47 -0700 (PDT)
MIME-Version: 1.0
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
In-Reply-To: <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
From:   Malahal Naineni <malahal@gmail.com>
Date:   Fri, 2 Nov 2018 21:24:36 +0530
Message-ID: <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
Subject: Re: "(deleted)" directories
To:     bcodding@redhat.com
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ben, NFSv3 RFC1813.txt states: "If two file handles from the same
server are equal, they must refer to the same file, but if they  are
not equal, no conclusions can be drawn." Ganesha does return same
fileid here (inode).

In NFSv4, they have introduced "unique_handles" attribute. I don't see
Linux NFS client using this at all though.

Regards, Malahal.
On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <bcodding@redhat.com> wrote:
>
> On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>
> > Hi All, we are using NFS-Ganesha with Linux NFS clients. The client's
> > shell reports the following. Based on lsof, the directory is marked
> > deleted. "cd to ROOT and cd to the same home directory fixes the
> > issue. The client behaves as though the directory is deleted and
> > recreated! Our NFS-Ganesha server implementation uses multiple file
> > handles that point to the same object. NFS spec says this should be
> > fine, but Linux NFS seems to be broken in this regard. tcpdump does
> > indicate file handle change (note that all file handles are permanent,
> > meaning they are valid at the server any time) around this issue time.
> >
> > "shell-init: error retrieving current directory: getcwd: cannot access
> > parent directories: No such file or directory"
> > sh        112544            malahal  cwd       DIR               0,67
> >      65536   45605209 /home/malahal (deleted)
> > (10.120.154.42:/nfs/malahal-export/)
> >
> > Function nfs_prime_dcache() seems to invalidate the dcache entry if
> > nfs_same_file() returns false. nfs_same_file() does seem to return
> > false with the following change, if I read it correctly, if there is a
> > file handle change. Can this be the source of my issue? It seems that
> > the client should do this only if the file handle is NOT valid (e.g.
> > if it gets ESTALE), right?
> >
> > The following commit seems to assume that the objects are different if
> > they have different file handles!
> > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
> > Author: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date:   Thu Sep 22 13:38:52 2016 -0400
> >
> >     NFS: Fix inode corruption in nfs_prime_dcache()
>
> My understanding is that for NFSv3 we have to assume that distinct
> filehandles are distinct objects, but maybe I'm wrong about this.
>
> For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530 section 10.3.4
> to determine if the differing filehandles are the same object, specifically
> the fileid recommended attribute needs to be implemented.  Is Ganesha
> returning the same fileid for both filehandles?
>
> Ben
