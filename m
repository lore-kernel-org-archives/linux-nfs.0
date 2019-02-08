Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 955CFC169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 11:20:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 659AA20863
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 11:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iYJNKzSs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726465AbfBHLUi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 06:20:38 -0500
Received: from mail-yb1-f196.google.com ([209.85.219.196]:34603 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726068AbfBHLUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 06:20:38 -0500
Received: by mail-yb1-f196.google.com with SMTP id k9so1279155ybg.1;
        Fri, 08 Feb 2019 03:20:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=K/5NuJhG2mS5tDdcJ+QiUDL2beRB0IqOqPlPkZzUgTc=;
        b=iYJNKzSsa65ixmrVsBdrjiCXMFVmSylokeIGZSQMKx6ETkNCo0dy9ER0hhNAtDPD/r
         nI8+9FAqwVMV/hflvqYiaiqibLkHfwb/gqeuqGdD6+6tfFadhC47olmhfWjeoF1kdluy
         wfPtA3KiuUJfG9d3cAcyeSfmJuX3Z6ElUuYaxB6hy/cfJilUmAQoEjkJXG7rb8ZXfYjP
         b4yOVvMb3X1lMRXugjj9vjw00ZZcvDOfFbbzIOKQZ/CuHYQECPa2vpAuLz8B+K4NhrVF
         OR1ZY2uAgsMcdsoSlhmKFScVybho+iZxRq4VdEMef2YxBkWQz+BO/6L4VtbsgQN+a2Ff
         lNSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=K/5NuJhG2mS5tDdcJ+QiUDL2beRB0IqOqPlPkZzUgTc=;
        b=lrsYlbwCsimiGh090CyHgS2WbgBW85/vxcCSCaq3ULNb+ZbI9CrRygiGdd6eDhkyN4
         4VnP6/MdFU1AfzTrJJilsFlFJQcxE9TXfEH/4aQa4dSuwGDWU4tleYyIw4Vzp2V9CVXe
         ZJUdreCKu8Ekxv8g/FJ9GI88E9ClxD7eRbTmKZkG53WP8xcXjJ7xolUjheGUsJjn6nmY
         iy5JYzpgp03na2vx/zQr+pvdWuCOlY7rF+lwEFP06eQbAVPJfoSucFOem5zCUo8VyzUn
         ygvPGOwYUns26vgPANeNXrbR9jl5rJMpiG3MZrLXPJsBYBTL/COyQ4HdOR40e4cMqo7d
         /vgw==
X-Gm-Message-State: AHQUAuaI/GlzXCuU3D/hUjAsG7HInZWRPqdtrKiim9yH46aI0c4BeaNQ
        uGfWyO6pZZWD/5kqRGeP39iAvGRVJCfCPr9vmPM=
X-Google-Smtp-Source: AHgI3IZvOqF566wMoug1jp2lMdX/KNWuZ8oHODeVjVLUb/G5jb0jK9R5l3KVQExICCCdqMg29P/BH8y7eWkhn7ugjE4=
X-Received: by 2002:a25:c087:: with SMTP id c129mr17494075ybf.320.1549624837290;
 Fri, 08 Feb 2019 03:20:37 -0800 (PST)
MIME-Version: 1.0
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Fri, 8 Feb 2019 13:20:26 +0200
Message-ID: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
Subject: Better interop for NFS/SMB file share mode/reservation
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Jeff Layton <jlayton@kernel.org>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Bruce,

I have been following you discussion with Volker Lendecke
on the samba technical mailing list [1] and have had discussed
this issue with Volker myself as well.

I decided to start this new thread to bring some kernel developers
in the loop and to propose an idea that takes a somewhat
different approach to the "interop" approaches I have seen
so far. "interop" in this context often means consistency of file
lock states between samba and nfs server, but I am referring
to the stronger sense of interop with local filesystem on the server.

You pointed to Pavel Shilovsky's O_DENY* patches [2] as a possible
solution to interop of NFS Share Reservation and SMB Share Mode
with local filesystems.
Some of the complaints on this approach were (rightfully) concerned
about DoS and the prospect of plaguing Linux with Windows server
"files left open" issues.

My idea comes from the observation that Windows server
administrators can release locked files that were left open by clients.
I suppose that an NFS server admin can do the same?
That realization makes "share access" locks (a.k.a. MAND_LOCK)
not so very different from oplocks (leases/delegations).
As long as samba and nfsd cooperate nicely with MAND_LOCK
semantics, we don't really have to force local filesystems
to obay MAND_LOCK semantics. If the file servers take leases
on local filesystems, they will not get exclusive write access for
files already open for write on local filesytem and same for read.

On local file access on the server that violates the share mode,
the file server acts as a grumpy washed out administrator that
automatically grants any lock revoke ticket after timeout.

This model may not fit use cases where "real" interop with
local filesystem is needed, but compared to the existing
solution (no interop at all) it is quite an improvement.

Furthermore, short of SMB DENY_DELETE, we may not even
need to change any kernel APIs.
The addition of O_DENY* open flags can make programming
easier, but taking a lease on an open file is still safe enough
to implement share reservation (no?).

Satisfying DENY_DELETE could be more tricky, but perhaps
the existing SILLYRENAME interface of==between knfsd and vfs
could be somehow utilized for this purpose?

I though of bringing this up as a TOPIC for LSF/MM, but wanted
to consult with you first. I am sure that you or Jeff can do a better
job than me in enumerating the "interop" file lock issues that
could be discussed in filesystems track forum.

Thoughts? Explanation why this idea is idiotic?

Thanks,
Amir.

[1] https://lists.samba.org/archive/samba-technical/2019-February/132366.html
[2] https://lore.kernel.org/lkml/1389953232-9428-1-git-send-email-piastry@etersoft.ru/
