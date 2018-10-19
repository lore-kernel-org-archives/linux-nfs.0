Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:33585 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726194AbeJTG3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 02:29:07 -0400
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 12EFE2801FB
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 00:11:36 +0200 (CEST)
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [IPv6:2001:638:700:1038::1:83])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 0F3D6A0040
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 00:11:36 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id D93D11029
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 00:11:35 +0200 (MEST)
Date: Sat, 20 Oct 2018 00:11:35 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
Subject: readdir request re-requests entries
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dear NFS fellows,

we have notice a behavior of nfs client when iterating over a big
directory. The client re-requests entries that already has been. For
example, a client issues READDIR on a directory with 1k files. Initial cookie
is 0, maxcount 32768.

c -> s cookie 0
s -> c last cookie 159
c -> s cookie 105
s -> c last cookie 259
c -> s cookie 207

...

and so on. The interesting thing is, if I mount with rsize 8192 (maxcount 8192), then first couple
or requests are asking for correct cookies - 0, 43, 81, 105. Again 105 as with maxcount 32678. To
me it looks like that there is some kind of internal page (actually NFS_MAX_READDIR_PAGES) alignment
and entries which do not fit into initially allocated PAGE_SIZE * NFS_MAX_READDIR_PAGES memory
just get dropped.

As 30% of each reply is thrown away, listing of large directories may produce much more requests
than required.

Is it an expected behavior?

Thanks in advance,
   Tigran.
