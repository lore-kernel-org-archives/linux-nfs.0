Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D802C6786F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 05:26:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB39A2081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 05:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OU485ShK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB39A2081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727751AbeKBOcp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 10:32:45 -0400
Received: from mail-pf1-f193.google.com ([209.85.210.193]:34622 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727745AbeKBOcp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 10:32:45 -0400
Received: by mail-pf1-f193.google.com with SMTP id f78-v6so482919pfe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 22:26:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=a4nQgj+VAZSMTauXFoNp3fS31xj1ohSV8M8lqls6Td0=;
        b=OU485ShKB70EX32omMnzx7RCx1Z6fh0t7BUn/MY35Us3J5o1lGEFSDGgDhQW+pjAlh
         lqceMHywEASIV1V5lYWePm0EE9SV+ySdkqRkTsjRWQulDlFrMT9kBfKKuQgqfgQsEYPE
         EzeZJFGaLjnrFS0R/yj6yLFgAnYX6SCK5cFSRTMTTxWfGXvFQyvDEH264YylRKdrbxyK
         y1UIPrJv0rPvOLnK58h1QqSkxYzk+vVcbUneJ6xeprfS7H80GgUnQDJn8p84psSP2SPL
         SIVtJSn8fW+78TTiAsWxh7f/UmYrknRRCU+q9LIRxXdrYQOnOyGUcXwp/RtoYaksB6x4
         Vn8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=a4nQgj+VAZSMTauXFoNp3fS31xj1ohSV8M8lqls6Td0=;
        b=dn1DyW185Fj+NL0Xl2gafOZFD70d1QzIQqQQqYKK0QBtEJmH2sinO6Ja8D+M1+KQZd
         UzXIHykfQjKKQyiaHRKWAdOSY080EuP/L5h2xMpwWBZLy9rBYac3zZ1L13Sn9tY6qbhW
         gw3OYCDnbMn+yVMiFzDYxVs8c7ubNCBS+WmzXjFkqVtAVT8EEaI9gCXsM8/zmXyMf5K5
         Mj74qSmhB5Qll4Imm+aE8q2wEnOsfyQOr1k3jEK5ePet7zyawvn43Zml9j99XSVfCeeK
         uBncxISC71iOlN9iVhgvBk1wH4FFaMeDcMl07IMJC8S2o6683oLykX3I58xmPkXiCxOa
         3o0A==
X-Gm-Message-State: AGRZ1gINflhvjAyvF5MTAuGnVzy3TLrvoV59dhlMWfbj6vXQhhko0cHI
        IIDUg1Ds9CnRZYh5kNxGUdl6R0k/1z/yoz6BAhbcp0m2
X-Google-Smtp-Source: AJdET5cd232n/4NMxc6r40N8EiQWTklsVBopb4zRAh0h2S/B5ac8jXqjJrVweN7o7zbz0UiDafDttRCI+pRfSei6WzA=
X-Received: by 2002:a65:41c2:: with SMTP id b2mr7900339pgq.67.1541136410540;
 Thu, 01 Nov 2018 22:26:50 -0700 (PDT)
MIME-Version: 1.0
From:   Malahal Naineni <malahal@gmail.com>
Date:   Fri, 2 Nov 2018 10:56:39 +0530
Message-ID: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
Subject: "(deleted)" directories
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi All, we are using NFS-Ganesha with Linux NFS clients. The client's
shell reports the following. Based on lsof, the directory is marked
deleted. "cd to ROOT and cd to the same home directory fixes the
issue. The client behaves as though the directory is deleted and
recreated! Our NFS-Ganesha server implementation uses multiple file
handles that point to the same object. NFS spec says this should be
fine, but Linux NFS seems to be broken in this regard. tcpdump does
indicate file handle change (note that all file handles are permanent,
meaning they are valid at the server any time) around this issue time.

"shell-init: error retrieving current directory: getcwd: cannot access
parent directories: No such file or directory"
sh        112544            malahal  cwd       DIR               0,67
     65536   45605209 /home/malahal (deleted)
(10.120.154.42:/nfs/malahal-export/)

Function nfs_prime_dcache() seems to invalidate the dcache entry if
nfs_same_file() returns false. nfs_same_file() does seem to return
false with the following change, if I read it correctly, if there is a
file handle change. Can this be the source of my issue? It seems that
the client should do this only if the file handle is NOT valid (e.g.
if it gets ESTALE), right?

The following commit seems to assume that the objects are different if
they have different file handles!
commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Thu Sep 22 13:38:52 2016 -0400

    NFS: Fix inode corruption in nfs_prime_dcache()
