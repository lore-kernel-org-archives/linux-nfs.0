Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8366DC32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 22:07:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D62F2082D
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 22:07:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D62F2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728359AbeKCHQd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 03:16:33 -0400
Received: from mail-it1-f174.google.com ([209.85.166.174]:53795 "EHLO
        mail-it1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726083AbeKCHQc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2018 03:16:32 -0400
Received: by mail-it1-f174.google.com with SMTP id r12-v6so2414904ita.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 15:07:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=NuMzUSUBJdCynv6p6+2KyTsR5yaSQWuM2xEDPOyQXaU=;
        b=O+6QErsSHTCMJpXGvzgO0VnB9HUTa3lfp5ZlTW52MNcdmZlpIS86BuOEv2oiAQwcj0
         Yo+fT4BQmKBCCSN19CoRAvLHocnyIVDihEtbHyZqWRtmMvrp7q5zJ5l8AY0n3e9YlMOC
         LWnzhhZuqvXfPA1mhvE/ipqKFyi4lwdCwsaAM8RxxNKyDeWZ1Awbt9FJ2dAONaKCuqB5
         XDwkk1bcIaYAQj9vPypj81IFVv0ChT62rI9HUrAdWYGGbFUoeplAp1bUR7bIbmcRu8Fi
         +XhQmt2QPyJbk2aYu/mNrQWgzA5VuSQLs5i4tdRNWXiSsPDQXgzvUlP6gFcWXQiAQ9fG
         t7FA==
X-Gm-Message-State: AGRZ1gKkfazT24vC73JKJAnjudEw83btAJYAzxoUJkb/rHwzNZ4Y8HpH
        lz/r13An8uPMMiZnqmIm76KzewlJ7ZCqi2pH1W9b5/5J
X-Google-Smtp-Source: AJdET5e62dyx9Sb65r6vAROcxr9DDAb5vpefv0s/qwQuLYsB5wZaeZyWKxlv7nMogqtEDv+uJnOSMcepYoFm5iaSRR0=
X-Received: by 2002:a02:e43:: with SMTP id 64-v6mr12532238jae.58.1541196457548;
 Fri, 02 Nov 2018 15:07:37 -0700 (PDT)
MIME-Version: 1.0
Received: by 2002:a02:ec5:0:0:0:0:0 with HTTP; Fri, 2 Nov 2018 15:07:36 -0700 (PDT)
In-Reply-To: <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com> <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
 <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
From:   Matt Benjamin <mbenjami@redhat.com>
Date:   Fri, 2 Nov 2018 18:07:36 -0400
Message-ID: <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com>
Subject: Re: "(deleted)" directories
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "malahal@gmail.com" <malahal@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

It sounds like a pretty good one, that goes to the heart of what a
specification is

Matt

On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <trondmy@hammerspace.com> wrote:
> On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
>> Ben, NFSv3 RFC1813.txt states: "If two file handles from the same
>> server are equal, they must refer to the same file, but if they  are
>> not equal, no conclusions can be drawn." Ganesha does return same
>> fileid here (inode).
>>
>> In NFSv4, they have introduced "unique_handles" attribute. I don't
>> see
>> Linux NFS client using this at all though.
>
> Why does your server need to have multiple filehandles refer to the
> same file, and why do you expect clients to support this?
>
> Yes, the spec allows it, but that's not a sufficient reason.
>
>>
>> Regards, Malahal.
>> On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
>> bcodding@redhat.com> wrote:
>> > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> >
>> > > Hi All, we are using NFS-Ganesha with Linux NFS clients. The
>> > > client's
>> > > shell reports the following. Based on lsof, the directory is
>> > > marked
>> > > deleted. "cd to ROOT and cd to the same home directory fixes the
>> > > issue. The client behaves as though the directory is deleted and
>> > > recreated! Our NFS-Ganesha server implementation uses multiple
>> > > file
>> > > handles that point to the same object. NFS spec says this should
>> > > be
>> > > fine, but Linux NFS seems to be broken in this regard. tcpdump
>> > > does
>> > > indicate file handle change (note that all file handles are
>> > > permanent,
>> > > meaning they are valid at the server any time) around this issue
>> > > time.
>> > >
>> > > "shell-init: error retrieving current directory: getcwd: cannot
>> > > access
>> > > parent directories: No such file or directory"
>> > > sh        112544            malahal  cwd       DIR
>> > > 0,67
>> > >      65536   45605209 /home/malahal (deleted)
>> > > (10.120.154.42:/nfs/malahal-export/)
>> > >
>> > > Function nfs_prime_dcache() seems to invalidate the dcache entry
>> > > if
>> > > nfs_same_file() returns false. nfs_same_file() does seem to
>> > > return
>> > > false with the following change, if I read it correctly, if there
>> > > is a
>> > > file handle change. Can this be the source of my issue? It seems
>> > > that
>> > > the client should do this only if the file handle is NOT valid
>> > > (e.g.
>> > > if it gets ESTALE), right?
>> > >
>> > > The following commit seems to assume that the objects are
>> > > different if
>> > > they have different file handles!
>> > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
>> > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> > >
>> > >     NFS: Fix inode corruption in nfs_prime_dcache()
>> >
>> > My understanding is that for NFSv3 we have to assume that distinct
>> > filehandles are distinct objects, but maybe I'm wrong about this.
>> >
>> > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
>> > section 10.3.4
>> > to determine if the differing filehandles are the same object,
>> > specifically
>> > the fileid recommended attribute needs to be implemented.  Is
>> > Ganesha
>> > returning the same fileid for both filehandles?
>> >
>> > Ben
> --
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
>
>



-- 

Matt Benjamin
Red Hat, Inc.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://www.redhat.com/en/technologies/storage

tel.  734-821-5101
fax.  734-769-8938
cel.  734-216-5309
