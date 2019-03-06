Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4BAFC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 10:39:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E58A20661
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 10:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OqShqfBU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728867AbfCFKj4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 05:39:56 -0500
Received: from mail-lj1-f181.google.com ([209.85.208.181]:37620 "EHLO
        mail-lj1-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727367AbfCFKj4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 05:39:56 -0500
Received: by mail-lj1-f181.google.com with SMTP id a17so10402153ljd.4
        for <linux-nfs@vger.kernel.org>; Wed, 06 Mar 2019 02:39:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=67aKe5ew9lb1oZqpvlRGJ1S5enHE2rTmxz1/WVYWlIg=;
        b=OqShqfBU7A2UkxKclFkdg8UlbWUZZBlgAsWuc+sYdVGL8XiiOMhNlKQ/49dUogRoDB
         LTPKL9fL1WgJCKsBuYYEpakzmxdSJg7PFwe8k/4jtaObeB8T0xqKaCPTXn42vjilhomy
         UoI89+N9pfkiJRUJ3wxtYlTls05sHq7I7n5TURSksNKH/uLSvJFZLDVoUFRPQ9FLTMtO
         vO3kWL1G0+L5oKEyCcMyOTItQggHL7sJEYNYXLzHJwic5sNrS8EyASIcCIB600QJ3qYl
         4c1/cF0zbVFMf2QfFXw3jsNYoYFFzxpxMp9Nyjww8KMOtCXqCLLRv8ndGrI2eKSum80Z
         MNpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=67aKe5ew9lb1oZqpvlRGJ1S5enHE2rTmxz1/WVYWlIg=;
        b=DpUaV3g995MGH42ovrtN8qjD5SFlV97+/NXTFRo395WlgTxplpkRrnlWwi+UnVlJF9
         2EGD55MmdiMXWOBC7do/VOmqarcq0WN0+YBaH5TGJsR1/hvHTfjJhKg5tfzhRZP02PZ7
         QECrOmwB+vEHxGbOuDz5ztv+qtp4EtJ/sbA0TTMsU/kuldkitcqRZzRMA1HG/NwH16LN
         teIdN+OsVIIqqaErCi8hUDxJ6XbXkjWiyEO4aKGQypSf1JDoqwSAe9NlVXRc1a8SwpK5
         YeJGCWaCoWeMfD0o7mp0tU6LBgvv3RaA94iDGiEZMibj8VPy23J/zvNgoT1Wk60khnhk
         8GyA==
X-Gm-Message-State: APjAAAWQM0vuiycbFjdmc+4NWYNhGHZJGZhTCEWE5w86K0Dyxhqh1lUH
        ufjyOojCobT/Gg/WGrD1TVYk2o1TrEXW1JWKqYvPvg==
X-Google-Smtp-Source: APXvYqz+qpUmshOXjo665LXhN+lMszu1WjLNaX72b4ctjVDyAqZCL8OxixUCIxKoyqyuv0VT7e3KmF2dlbY7cuufOjM=
X-Received: by 2002:a2e:5518:: with SMTP id j24mr2073282ljb.80.1551868793875;
 Wed, 06 Mar 2019 02:39:53 -0800 (PST)
MIME-Version: 1.0
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
In-Reply-To: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
From:   Kanika <jr.kanika@gmail.com>
Date:   Wed, 6 Mar 2019 16:09:43 +0530
Message-ID: <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
Subject: pnfs setup on Linux 4.15
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,
I am trying to deploy pnfs using the mainstream-ed NFSv4 server/client
available with 4.15 kernels. I have been able to setup the MDS and
client using the flexfile layout. I can't find any documentation on
how to inform MDS about the data servers.

The setup I have so far:
Metadata server and data server are running Ubuntu 18.04
Client is Centos 7.5

MDS (intended), ip: 192.168.122.92
root@ubuntu1804:~/#cat /etc/exports
/sudosrv *(rw,sync,fsid=0,no_subtree_check,no_root_squash,pnfs) <-- PNFS set
/sudosrv/share1 *(rw,sync,fsid=1,no_subtree_check,no_root_squash)

Intended DS, ip: 192.168.122.83
root@ubuntu18_04_2:~#cat /etc/exports
/srv/homes *(rw,sync,fsid=4,no_root_squash,no_subtree_check)

Client, ip:192.168.122.5 (Centos 7.5)
Mount the pseudo root filesystem exported by MDS

#mount -t nfs -o v4.2 -o rw 192.168.122.92:/ /mnt/
#cat /proc/self/mountstats

device nfsd mounted on /proc/fs/nfsd with fstype nfsd
device 192.168.122.92:/ mounted on /mnt with fstype nfs4 statvers=1.1
opts: rw,vers=4.2,rsize=524288,wsize=524288,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.5,local_lock=none
age: 127
impl_id: name='',domain='',date='0,0'
caps: caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
nfsv4: bm0=0xfdffbfff,bm1=0x40f9be3e,bm2=0x20803,acl=0x3,sessions,pnfs=LAYOUT_FLEX_FILES
 <--- flex file layout
sec: flavor=1,pseudoflavor=1

I tried 2 ways to link MDS and DS
1. Use the "refer" while exporting the DS share from MDS. This works
as referrals are expected to work but not like "pnfs".
2. Mount the DS on MDS in a subdir of /sudosrv/share1. All IO
operations go only to the MDS as if it were a local share. No exchange
between the client and the DS.

How can the DS be known to an MDS for a local filesystem like ext4?
Any help will be appreciated.

Thanks,
jrk
