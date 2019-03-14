Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D64EC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 19:32:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 04394217F5
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 19:32:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l/0gvBKP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727142AbfCNTca (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 15:32:30 -0400
Received: from mail-it1-f177.google.com ([209.85.166.177]:55446 "EHLO
        mail-it1-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726972AbfCNTca (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Mar 2019 15:32:30 -0400
Received: by mail-it1-f177.google.com with SMTP id z126so3789589itd.5
        for <linux-nfs@vger.kernel.org>; Thu, 14 Mar 2019 12:32:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=2/G8x+UcEfldaHHpZ+YD3XiVNMGSMFCst4ACJPgZUq0=;
        b=l/0gvBKPs7X1k1cIhTPw6hm5Vu8QiG94g4KqEaoKU37vO48nAD6iT/FcKJX1xoRZ9e
         KtVV/D8XLoNQueghGEGy7451TXOuB/zzawglwVcElBJBmcxh/TMDAWJNhOfmNVj4TYMj
         DyyZJ/HJzMSJ/E7i0DuvOkRxG72exYeWctSGbk2tNPTUSWrWjpRHHb9rQsFEL/USZ9xM
         /Kofus9JB8po7hZZQTFmVFaqpfcDgOp5qYu63uQ4JW2aanzapOstxf81Btjjjk4XFfIt
         CbKfYsUTlVG2JKejy7WjS7xwxc2IC2AGrdmcn+UAoG2S/9RyW7ScqRqNle+tScjovQEM
         UWYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=2/G8x+UcEfldaHHpZ+YD3XiVNMGSMFCst4ACJPgZUq0=;
        b=Fk5hLHR4hNyvS+YHWClFibBBJISiQMj93zKpBo7I5cjdJqPwIQRA5RvCfpASTOg1uz
         pKSjjC5KEZie5McPuLWg6dQsvRMXrSx4TY80+ZrTpkRkbudvCrg+uDqKO45k3Ip6Vlht
         s2O/tfovwzlmrtQTui3PuGCKQhaMH9GvcId1CQYhTRhnm/RCpW46WMOR0N8zsrDfbuk2
         O2+uwoy874AX1g05yvk2CZ/S2MOwjQJSqcUlBMpaI34V2CrnfOP+ZjgMzvfDN2HGPHj9
         O+okMGkkmmqNLMaA2S3OjVUp2N5VtMIDLQWf2PWTKlGzFG9p5g7SqOdLXtbeYUeZQ1b+
         +SCg==
X-Gm-Message-State: APjAAAWcqqoobeAlLAACA98HSbvTgQ2/1stPv5AQ9idv/lPWuY3Fnjeo
        ZZEJstbygRC+vxKriGYT9p6JmIlL18CMVxNuUw1OZOAG
X-Google-Smtp-Source: APXvYqxrUCln2LhELXqu/L8DevsyYU6XeQZqRRH+jTWDotNZIK0pQxNA6RZmeLwz8yqf24od2gEiJrfbLovwYonoORk=
X-Received: by 2002:a02:9831:: with SMTP id t46mr940557jaj.140.1552591949216;
 Thu, 14 Mar 2019 12:32:29 -0700 (PDT)
MIME-Version: 1.0
From:   Marc Dionne <marc.c.dionne@gmail.com>
Date:   Thu, 14 Mar 2019 16:32:17 -0300
Message-ID: <CAB9dFduu5_UDP_G-QXiYCYMPoytMOJQJ5OxXB02rGtbfMXO5BQ@mail.gmail.com>
Subject: Hanging nfs mount - bisected to merge commit 06b5fc3ad94e
To:     linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I have an odd nfs issue with the current mainline kernel, where a
mount hangs and eventually times out when attempting a mount with nfs
version 4 and that is not offered by the server.  With prior kernels
it fails quickly with "mount.nfs: Protocol not supported".

To reproduce, I have rpc.nfsd start with "-N 4", then try to mount
something local with -o nfsvers=4, for instance:
  $ mount -t nfs -o nfsvers=4 localhost:/s /mnt

I bisected the behaviour down to commit 06b5fc3ad94e ("Merge tag
'nfs-rdma-for-5.1-1' of
git://git.linux-nfs.org/projects/anna/linux-nfs").  It's a merge
commit, but one that has quite a bit of conflict resolution.  I also
verified that the 2 parent commits of the merge (5085607d2091 and
2c94b8eca1a2) both behave as old kernels did.

Thanks
Marc
