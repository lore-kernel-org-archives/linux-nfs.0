Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 692FEC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 09:12:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 39DD32177E
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 09:12:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kz2cPhcu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729424AbfBRJMA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 04:12:00 -0500
Received: from mail-ed1-f46.google.com ([209.85.208.46]:40011 "EHLO
        mail-ed1-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727423AbfBRJMA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 04:12:00 -0500
Received: by mail-ed1-f46.google.com with SMTP id 10so13168184eds.7
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 01:11:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=v00oJVVKBPM6V/InQnC4p8NWlIJO/3CtmYRXWltfIZ8=;
        b=kz2cPhcuIzcX8BCaEo+q7zednl7L/j2KjpNH8Zu405O5WKUaOnph9oiwc9JqcCXnk+
         UZwJVDkrxBaBENqp7tAPLiEcRfsMgGWaoOlo8TPbNZPK9CMX+NjbymNgE/DWg3dBKsdB
         BZupN8YWSz09SMD/WKGnKJRKC3AQwFOGn14ev8qM+EiOcgOuw6h125Imiv3HK6tqM9K3
         HX6Hxe9dussuRnwIpXONxEAaJoeh3ChnN9OivKMcez3Q82dbbn0s7yDhZcBZ4evqxQ4C
         jOfWR4af13YUlkSQGKEmXj36IOFP5WRXb599PsXJLcsRrOOX9g6xLb/EqlD2X+FhZblo
         k7OA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=v00oJVVKBPM6V/InQnC4p8NWlIJO/3CtmYRXWltfIZ8=;
        b=t02tapdLQ3pfroUhQNx9DsTUQlqfMisvPZksyDDN5EMq4r35AEJ6uF/1T0UmdJAB9W
         MlN/owOgWVj3JZoCZvpqpuGH8QvtVXx8XVHpApcut7Ppzwo6n5Ue0kOcCGAOVrcAO9l4
         MoMoZtw+CWOK9xPA5SBuF2V0WMBMMzyqTI5VC+sY2pI8XfGI04BAdNjIrIRknJ2stJfV
         RcSZfsJNxK0LdP9Qb35hOfZVAn+8lNzkCEv8mjKlUNE3r6xsQK3EQT2MgOWmvUtPZTpt
         SssYXbGC0NAnPwlDuruPQwn5DrEksQyYNQsEmOCpt9jhpwVhpRdaravW07K19JnBT2KV
         HiBw==
X-Gm-Message-State: AHQUAuZtVYvkmmvwz9U5OFsaYe9Wi/fZg0sf41ve/6H0N5awuMA8ItoK
        AAqZAWCFBYf6cDYtiI1QHq9rrFochlIP0bd5uH57G3Yo
X-Google-Smtp-Source: AHgI3IYXFmDhcNjmHIqxZjRJjF6MOUBOGAZTHfHrbi+gJ/iboAhjjcT+AWsTCPWbFjUdkDWbcJwbxeiDFbBo7SIqQ14=
X-Received: by 2002:a05:6402:1682:: with SMTP id a2mr4258971edv.158.1550481118177;
 Mon, 18 Feb 2019 01:11:58 -0800 (PST)
MIME-Version: 1.0
From:   Gefei Li <gefeili.2013@gmail.com>
Date:   Mon, 18 Feb 2019 17:11:47 +0800
Message-ID: <CANidX5RGLuvdS82TpxuagUsA4DmUochDv2AwX7rwHdD-q+Khbg@mail.gmail.com>
Subject: linux NFS client lock file cannot get a expected response
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi NFSDevs,

I am recently testing linux nfs lock with NFS share from a WinServer
2016. I tried to write a file which has already been locked with fcntl
exclusively, but the response of `write` syscall is neither
`Permission denied`, nor successfully written with file content
changed. Here is several experiments I did:

The first shell runs c program, calling `fcntl` to lock file
exclusively =E2=80=9Cfcntl(fd, F_SETLKW, &fl)=E2=80=9D

2.1 The second shell tried to open with flag O_RDWR, and write a
buffer to the same file, write returned the correct bytes written, but
the file content remained unchanged.
2.2 The second shell tried to open with flag O_RDWR|O_SYNC, write the
same buffer to the same file, write operation returned EAGAIN
2.3 The same operation on ext4 file system gives me a expected
behavior the same as advisory lock expressed, successfully written
with file content changed.

I reviewed NFS 4.1 protocol(RFC 5661 page 185), the nfs server can
determine whether byte range lock can be either mandatory or advisory,
but I think 2.1 and 2.2 gives me some unexpected behavior as these
two.. What=E2=80=99s your idea about this? Can you give me some tips to wor=
k
this out?

Looking forward for your reply. Thanks in advance!

BTW, my linux kernel version is 4.15.0, linux release: ubuntu 16.04
from Azure marketplace, my nfs-common version is
"nfs-common/xenial-updates,now 1:1.2.8-9ubuntu12.1 amd64" from ubuntu
apt repo.

Thanks,
Gefei
