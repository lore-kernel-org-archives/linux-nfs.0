Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99B24C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:57:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5EA4920811
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:57:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gRsW5s3A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EA4920811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726263AbeLLS5Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 13:57:25 -0500
Received: from mail-oi1-f170.google.com ([209.85.167.170]:37340 "EHLO
        mail-oi1-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726249AbeLLS5Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 13:57:25 -0500
Received: by mail-oi1-f170.google.com with SMTP id y23so15913968oia.4
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 10:57:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=X4R/5MWSkHjx+rcwZpnWWTr891Gorl6hzFds0cXjA/s=;
        b=gRsW5s3Ags/fLoYGfvwZ0ECe2+KsV2Uazs06g7qX8+Q3hFtylZRgnJBte5nVI+R7qS
         ZrEBdiKH2gU+AF9z/xKcF+s3zYGbXP5ISV0rj+oDDB7D+SyF2lSUzoP+y3lQtA1enyYu
         qYq3nJRDv/dnViAcim+IMrJpFzltrC6lbW/zebfychIN7gFWaOaeqzmjIq10CnlpquTb
         pqVjlKPCPuLc6towSAnoi43rS3iMuPcXHgPHP1XZQWhzoZgp9bTs+cynjx6FRFKI+a3T
         DCZxUpo4XCcnBTk76tfOEoxi5ptbfdLDM+hvWFqoksywq79/tGCuLST5f0IGsk2ma6pn
         HCUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=X4R/5MWSkHjx+rcwZpnWWTr891Gorl6hzFds0cXjA/s=;
        b=EbEIQDCqJ6UAiIes/QdvRQPHttdiM4A3a6DApcyAZaXVo6wZ2YhrLU5lYbN9TpxaH1
         tVQktkWnqzsiNlf/Zt18IZEytj3xzE67SKTLjMMBw2hC60fj2QM3KlYwb9BM49DvEEJh
         /1iTWyYOOrDjXJwCKkJi8a+Im1hLisnj0kvU+wKqh/yQhK6eoUcs/C3lWzZd1vt/XwX7
         5aLR/p2ENqgGvkBkEFJ4PNmUKseGYla6z0IXitvfPTPkuHOjTl4R1VWR8luPYyTRPuCx
         P3vfj+LuQOxXznpVK3ni/+9zX5vswzazeF443iWI/5AtAxbFq4HR6aM9KnghJdKK7TnS
         7gcQ==
X-Gm-Message-State: AA+aEWYlXGvjI7PrvK0tbyw2bcmvYjN4+1t9GS6fyor5gym6DPz+gGBP
        aJEPl8b3aW49pfyUecGLlHalT3KRETawSyJPe+WzZHny
X-Google-Smtp-Source: AFSGD/W2km2OCZcsziPByBdFMXt1zt6cnVCjGTRKchKhLVXSng07X0ZQaKKok9HhyNAo8R1vU/JwRG6Sh2ZUMA7AnNk=
X-Received: by 2002:aca:ad14:: with SMTP id w20mr258496oie.3.1544641044329;
 Wed, 12 Dec 2018 10:57:24 -0800 (PST)
MIME-Version: 1.0
From:   Ashish Sangwan <ashishsangwan2@gmail.com>
Date:   Thu, 13 Dec 2018 00:27:13 +0530
Message-ID: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
Subject: Handling of duplicate inode numbers for the directories in the nfs v3
 kernel client
To:     linux-nfs@vger.kernel.org, neilb@suse.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

Our NFS filer can sometimes return same inode number for different directories.
For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
and dir4 might end up returning the same inode number to the client.
Though it can never happen that inode numbers will be same for two
directories and also there parent is same. Can linux client handle
this case? What issues it can cause?
https://lkml.org/lkml/2006/10/2/346
I stumbled upon this thread where it is written that nfs client can
handle this but userspace will see inode collisions. Given that this
will happen only for directories, userspace utils logic might not get
affected from this as hardlinks on directories are not possible. But
the thread is really old. Wanted to confirm if this holds true even
now.

Thanks,
Ashish
