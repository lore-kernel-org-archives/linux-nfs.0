Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3391C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 15:52:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B784D20865
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 15:52:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B784D20865
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726357AbeK0CrT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 26 Nov 2018 21:47:19 -0500
Received: from mail-oi1-f196.google.com ([209.85.167.196]:35095 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726355AbeK0CrT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2018 21:47:19 -0500
Received: by mail-oi1-f196.google.com with SMTP id v6so16263139oif.2
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2018 07:52:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=GHIXxUm9nCrPnebgbOuiJbNPHCb8AziLbHD0EM1qguo=;
        b=HzAqP88aZ4m0g1z0OozkX8FsL/hDFaKjws3al7FxalKvufd/9QQes238tPRPw9sw1y
         LCxTWTeIau9x5rCQ9lho9fHBBpV2mrVKr74pBtw7tLU+z8XO/Bu2paREXt0ls4/St6IO
         w6GIw7aMUX7Je9rmLo0OV0QnRw09rTcOJQ2Hkc7vdh8Sgig6gjwThsWD3MzhkA+Pk+ZB
         8YbDBv0W/Cy7yfHNNYzaxpI9TmdieCqbol0qe45RHrhVuvWvjVLblBecrc4DHC4JPROH
         yySWaaZ7hNtEv8NlhCfp/VblR0idO2wyaIfeHSoo4vxQ3QVfaNyjuQf/binoV29GZXaz
         7WBQ==
X-Gm-Message-State: AGRZ1gJ3ReS1+5eujp2pTLMZdA8ejguL0eg1D5RBYqjthej0Z/xEpjNH
        0rzyBSutqIb7FsMhR2FkXf8bF75RYWcNvcmKAgIU9phK
X-Google-Smtp-Source: AJdET5efJ+qDstzkaQE00ZBYI6SIk8/uTZFpehBNxNchOD1d1y2S1P7Ly9b8R58VyKDzI/R/LNt+Hvmq+9wZbMdmGkM=
X-Received: by 2002:aca:3785:: with SMTP id e127-v6mr16144821oia.147.1543247568812;
 Mon, 26 Nov 2018 07:52:48 -0800 (PST)
MIME-Version: 1.0
References: <alpine.LNX.2.21.1.1811241957260.23228@winds.org> <20181126140730.GC27372@fieldses.org>
In-Reply-To: <20181126140730.GC27372@fieldses.org>
From:   Andreas Gruenbacher <agruenba@redhat.com>
Date:   Mon, 26 Nov 2018 16:52:37 +0100
Message-ID: <CAHc6FU4jup+MxRky2pmVm89L=D42E2Q35s6G-sUSUL-tmXzX-w@mail.gmail.com>
Subject: Re: NFS v4.2 umask getting dropped
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     gandalf@winds.org, jlayton@kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 26 Nov 2018 at 15:07, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Sat, Nov 24, 2018 at 08:18:40PM -0500, Byron Stanoszek wrote:
> > I would like to report a problem with NFS v4.2: the umask seems to be
> > getting dropped when creating files. This works as expected when
> > connecting with a v4.1 client or any version prior.
>
> In 4.2 the umask is sent in a separate attribute, in earlier versions
> the umask and open mode are combined by the client and only the result
> is sent.
>
> So probably either the client is sending just the open mode (with the
> umask applied) and neglecting to send the umask, or it's sending them
> both correctly and the server is ignoring the umask.
>
> Watching the network traffic in wireshark might help determine which
> side is at fault.

Right, a network dump (tcpdump -w) of the incorrect operation(s) would
be great so that we can have a look with wireshark.

> > Here is an example shell session:
> >
> > root@client:~> mount -overs=4.1 lnxsvr1:/users/files /users/files
> > root@client:~> cd /users/files
> > root@client:/users/files> ls blah
> > ls: cannot access 'blah': No such file or directory
> > root@client:/users/files> touch blah
> > root@client:/users/files> ls blah
> > 0 -rw-r--r-- 1 root root 0 Nov 24 19:54 blah
> > root@client:/users/files> rm blah
> > root@client:/users/files> cd
> > root@client:~> grep files /proc/mounts
> > lnxsvr1:/users/files /users/files nfs4 rw,noatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.11,local_lock=none,addr=10.0.0.2 0 0
> > root@client:~> umount /users/files
> > root@client:~> mount -overs=4.2 lnxsvr1:/users/files /users/files
> > root@client:~> cd /users/files
> > root@client:/users/files> ls blah
> > ls: cannot access 'blah': No such file or directory
> > root@client:/users/files> touch blah
> > root@client:/users/files> ls blah
> > 0 -rw-rw-rw- 1 root root 0 Nov 24 19:54 blah
> > root@client:/users/files> rm blah
> > root@client:/users/files> cd
> > root@client:~> grep files /proc/mounts
> > lnxsvr1:/users/files /users/files nfs4 rw,noatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.11,local_lock=none,addr=10.0.0.2 0 0
> > root@client:~> umount /users/files
> > root@client:~> umask
> > 0022
> >
> > The "blah" file gets created with mode 0644 (as expected) with v4.1, but mode
> > 0666 with v4.2. I've seen the problem so far across Linux 4.18.x and 4.19.x. It
> > happens as any UID and not just "root".
> >
> > The file is created via this system call:
> >
> > openat(AT_FDCWD, "blah", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK|O_LARGEFILE, 0666) = 3
> >
> > A cursory Google search revealed this URL which suggests the problem has been
> > happening since Linux 4.15:
> >
> > https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1779736
> >
> > I've attached a copy of my Linux kernel config used on both server and client.
> > Perhaps not having NFS ACLs enabled is the cause:
> >
> > root@client:/usr/src/linux> grep ACL .config
> > # CONFIG_EXT4_FS_POSIX_ACL is not set
> > # CONFIG_BTRFS_FS_POSIX_ACL is not set
> > CONFIG_FS_POSIX_ACL=y
> > # CONFIG_TMPFS_POSIX_ACL is not set
> > # CONFIG_NFS_V3_ACL is not set
> > # CONFIG_NFSD_V3_ACL is not set
>
> I can't see off the top of my head why that would be related.  But I
> doubt that configuration gets much testing, so it's worth a look whether
> we're doing something weird in that case....

What filesystem type is /users/files on on lnxsvr1?

Thanks,
Andreas
