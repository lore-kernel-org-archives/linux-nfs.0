Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5FB3C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:51:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8679420857
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qCTdMaa2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726466AbfCSPv6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 11:51:58 -0400
Received: from mail-wr1-f49.google.com ([209.85.221.49]:41780 "EHLO
        mail-wr1-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727184AbfCSPv6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 11:51:58 -0400
Received: by mail-wr1-f49.google.com with SMTP id p1so21738471wrs.8
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 08:51:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=1nVUyL+yDqVGc9R4Qzcagt2NVTTVb6i76B0ddsmD5VQ=;
        b=qCTdMaa2NtNP+VECdB+4iULAMQNY1OaXftsIc8VcBUzfJWnmkykr6as1Zhxm8ldsiB
         N2KFva9rg37Ir74/JGQ1atXXEAH2gAGTDyu+CccuDxE7lca3vANfP/sVo1lTjIKhMbmi
         KaHLFe/AI7b1RcTnmxyInb7WvWd+h4bezn/D5TaHG671f6Noi1gU+JPTdvLYxV0Md4+W
         iE0r7I6ygSK/l5L+a4XEdCI3KkRcQGmKZ7/Dz7QBnDftjqEBfOIsKjKIL5togF3al5cz
         YuQgvMOCsyIgk7ojGnUr7rNfFKxg9sxXlAVAk0soh97fjClMuaqK7yBgzigxu4A9RFvn
         Bxaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=1nVUyL+yDqVGc9R4Qzcagt2NVTTVb6i76B0ddsmD5VQ=;
        b=O5vwcanC2N9Tq7m0QOVF/hFdNqpBioRIdmdXCIbuZr2TSnswjzbEhYOIw82Y4d9uNs
         m+B8y9lROwaI/iwMk+wjhk1+X20X7tuILGGEgHodC1wwOD/qoUgNmXuhLaOdD16HoYBa
         /lWz85HNn2cBYle0CSTzGsgzAI/kEBiYA+jU5koB2ZRpNFFubQgaMekdI13cxlfbNmOX
         rtwPm53lIbdfC5BbjRYycv4OMEwObujBRqCpcwoNrkZZBZkIw5TObn0+mB0GA2dyOnEh
         Ra0bD0lxVcxG5Vq3YCPIz4JWtfWVpRXPLI4v5ZKcVxpRfO4UPdRprUAP3fLbITImeUjr
         yK2A==
X-Gm-Message-State: APjAAAWH+McjJx8vJuNygECttLfy35nZmiOvBEkOv+Z+4JO5hS1xsyIB
        okdD3YK17clSEgFrKIJr+k+n1uovSpz1y8mGNqwP3+JO
X-Google-Smtp-Source: APXvYqy0dg0LD0bt6IWiD8uz+5DEgv3HRFrl2EMmM2BgncZ+It+S0XRV2cuwEB4IldbNrvgDLq7o1NdQpg7QRviYLek=
X-Received: by 2002:adf:e949:: with SMTP id m9mr18667079wrn.1.1553010716615;
 Tue, 19 Mar 2019 08:51:56 -0700 (PDT)
MIME-Version: 1.0
From:   Naruto Nguyen <narutonguyen2018@gmail.com>
Date:   Tue, 19 Mar 2019 22:51:44 +0700
Message-ID: <CANpxKHExiJUMFBySUU0kixEV3d00Mo5Ze-matCans5JcOF5BhQ@mail.gmail.com>
Subject: Cannot check if nfsv4 is running or not by rpcinfo
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi everyone,

As the information from this link
https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html-single/storage_guide/#mount-shares-instance,
I see that we have to query if Manila nfsv4 is running or not by:

rpcinfo -T tcp -a 172.17.5.13.8.1 100003 4

I cannot use

rpcinfo -T tcp 172.17.5.13 100003 4

It will be stuck and other command like " rpcinfo -T tcp -n 2049
172.17.5.13 nfs 4 leads to "rpcinfo: RPC: Port mapper failure - Timed
out" but these commands are  successful with nfsv3 and even on some
other nfsv4, not Manila nfsv4.

Could you please let me know why I cannot use other commands, but have
to specify "8.1" (2049) in server address? Does it depend on nfs4
server implementation or if we have any specification standard to
query nfsv4 running?

Thanks a lot
Best regards,
Naruto
