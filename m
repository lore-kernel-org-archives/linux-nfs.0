Return-Path: <SRS0=mp2p=OS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 079E2C07E85
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Dec 2018 13:07:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8C1382081C
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Dec 2018 13:07:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jPrUMhM1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C1382081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726169AbeLINH4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Dec 2018 08:07:56 -0500
Received: from mail-qt1-f176.google.com ([209.85.160.176]:34395 "EHLO
        mail-qt1-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726166AbeLINH4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Dec 2018 08:07:56 -0500
Received: by mail-qt1-f176.google.com with SMTP id r14so9521145qtp.1;
        Sun, 09 Dec 2018 05:07:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=cbb+7JWzt3riyiZ8lDRwClewxqEJslYLQAMzLzgdpps=;
        b=jPrUMhM1SymOughLny82znHxwySjHuP1XlwMi5ZUKILg7bAW5aqOj5SiMwAGfJaBkO
         1EJt7VzTztMyzsG04lyDz/9PgyajQiXIosKjXr7G54ohbMTrSKgDXV6DppfkGOd9puvD
         IGsevC1KZb3cQO8CWwp+n3XgMtzJFCpPnM6op7czOCX+RgNpQEwa+moL4fwQa1wePgVK
         rQiwqVrfddsxkYVBu9HAEk6qucklDFG+cJ8SNRa+N4aHMCxdEjLFByObBoS0xEvNKZdr
         guh/CLPTZQsAWX5S+ZS9Dc96s2WfNamMtPKby/MhLWDWZFHeZP+13wZ9Y+o3W3lW2z1i
         EvCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=cbb+7JWzt3riyiZ8lDRwClewxqEJslYLQAMzLzgdpps=;
        b=GZrykengzsA6Mp+ktKX/uUBcpyScnQY8DYMhkV6dMjWY3v+f6xKduk+PJbitEkc2lg
         nqnCFTfcsK5bpn6hQKQZ4DKX47mg4GDS+81KASim5tNwCbYhDzlLlpIG2lYhoznjYrr0
         ONGQvcUFINzJK1lFaSw2NgjwxFrSdFusqEisP3cXSz4BtFM5Yu5TVu2BqzoPp9bMncOs
         k+yyP7thzxAgQes9YmrdEf5e6wP5+nueuZWEH2DaRghrEBjf+ApdIKcUa8m4yV66ULJh
         i9Y9OWnvtJYNynJQXUSQf/tP05RPCg6MiFqbu7k2KBiIgr7xMcU67NTVTG7iJERXKuth
         +e7g==
X-Gm-Message-State: AA+aEWa2PdQHonGZv1KBW8U3e91DD6FVNlidOgkzGBTipkFSIK1An99m
        ztRh/AAoQNX2IX0Pae8pPNn3PHlbQ1IQoMv2C+9aC0LdRko=
X-Google-Smtp-Source: AFSGD/WHcvsedcUBuwcm6yuCP6KBuANfal27Bzbbi51TY/yQlXy9GlwkcWSPN+7Fk5BXrqzvWL9vAmMscCUIO+WXNGs=
X-Received: by 2002:a0c:919d:: with SMTP id n29mr8089216qvn.202.1544360874782;
 Sun, 09 Dec 2018 05:07:54 -0800 (PST)
MIME-Version: 1.0
From:   Guk-Bong Kwon <gbkwon@gmail.com>
Date:   Sun, 9 Dec 2018 22:07:26 +0900
Message-ID: <CAJ-WH_xqdJVyA7mMmoqAkbJoOcsvgm9cF--NQADfd+pp_oRbEw@mail.gmail.com>
Subject: There is no 'no space' message when using xfs with nfs.
To:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

hi all


i use xfs filesystem over nfs


I am using the xfs file system via NFS on two Linux servers.

Even though xfs is full, you will not get a 'no space' message through nfs.

The server's load average goes up and the kworker consumes the CPU.

The server's nfs service is not responding.

When ext3 is full in the same environment, I get a 'no space' message.

Which part of nfs and xfs should be checked?


Below is the environment I am using.


kernel : nfs server 3.4.113 vanilla, nfs client 2.6.32-573.el6.x86_64

nfs : nfs v3 with tcp


==================================================================
nfs server
==================================================================
/dev/mapper/lv2  500G  500G   20K 100% /lv2

/lv2    0.0.0.0/0.0.0.0(rw,async,wdelay,nohide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,insecure_locks,no_acl,fsid=1543743056,anonuid=65534,anongid=65534)


==================================================================
nfs client
==================================================================
10.0.0.20:/lv2   500G  500G   32K 100% /mnt/2

nfsstat  -m
/mnt/2 from 10.0.0.20:/lv2
 Flags: rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=10.0.0.20,mountvers=3,mountport=2047,mountproto=udp,local_lock=none,addr=10.0.0.20


==================================================================
server top log
==================================================================
top - 21:54:10 up 58 min,  0 users,  load average: 8.50, 8.37, 8.83
Tasks: 347 total,   2 running, 345 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  4.2%sy,  0.0%ni, 95.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
12368 root      20   0     0    0    0 S   12  0.0   4:32.44 kworker/2:2
11092 root      20   0     0    0    0 S   10  0.0   4:42.57 kworker/3:1
11166 root      20   0     0    0    0 R    9  0.0   2:09.47 kworker/5:1
12473 root      20   0     0    0    0 S    8  0.0   2:09.36 kworker/4:2
 2944 root      20   0     0    0    0 D    6  0.0   2:09.10 nfsd
 2953 root      20   0     0    0    0 D    6  0.0   2:24.65 nfsd
 3024 root      20   0     0    0    0 D    6  0.0   2:23.12 nfsd
