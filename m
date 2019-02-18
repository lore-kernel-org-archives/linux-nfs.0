Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,MAILING_LIST_MULTI,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4175CC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 14:27:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 076A721900
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 14:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fvAhMfai"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389221AbfBROB6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 09:01:58 -0500
Received: from mail-ua1-f43.google.com ([209.85.222.43]:45524 "EHLO
        mail-ua1-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388705AbfBROB6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 09:01:58 -0500
Received: by mail-ua1-f43.google.com with SMTP id e16so5814044uam.12
        for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2019 06:01:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=YZUMslW8emH18FP1Td4Zm004uIqmtdi3O+sIH3dNlIQ=;
        b=fvAhMfaig1rKjfO+5WGh5vvphfMYNEL4lQW4D2iJ2BG5UzBZxGHEpHIT10RlDDwSDd
         50zEMmREDAjYeOIoh8fD9zjnNH3IRJC5pmw29nwiURm740HguwNgLGXYKfl9tFTODYvr
         j/EcLuS9+mad763POiopDpRzrYNXcNGqPq5fQ27mf9broc2E+uPOIcsCaiEAGGaL9Kdf
         A9NQSA+0NYAWHUExmC50P1KRyYJAdq5y4kXM9iPjbAM0UK2/h4puRTAlKMNIAZNbjaLE
         7pWYzE2mnEKbMcEjYfy0J3X9QFYY+iOLT2ZPK5wSOSJMP8W5OLFwItBb39PY5WExPoyb
         ZapQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=YZUMslW8emH18FP1Td4Zm004uIqmtdi3O+sIH3dNlIQ=;
        b=dIQz19rGmctbXnh+4wd3Ql6hlDJGotOvVmovD6JyrsG5LD0Boxnv0HioJsAUhw9yPs
         hBX0v1zS0OJ/mNF+U16NMhagekWK1OYJT54bDgZdEvtMGWV5Q1j895FEHD9Qwl0gXPRR
         VlU/PvgmoJ6Tg06BjP+iHTVPEF9MbZvh2HrI35+tuBK/X8uI0veW27+TKwksBvDdRED9
         zI3AcwENnBGDeDqBxn0Qy7XPI39moisCpHWwsguKkcTGnYfm65lCAkU6wHPlCWLdQMTh
         yupqM2INSeeM/cCtzXqphB1CpNCUG25C8afBCLe9vXeUw9IV0Tadb1i+JzDAYZp1fRl2
         MTmQ==
X-Gm-Message-State: AHQUAuZavSQugk8pcLoKLmOxaN1FOxUQ+bb/kyfP7iIhqAR3bbC6nP+A
        TWRMINUWInNLCUYjnTBtSM6IUD2QRKDSdqQPNiXwFxniuAM=
X-Google-Smtp-Source: AHgI3IYlI2Y/8gOl/Vs0N7IJnwBvT2+FqkvUv8Tx40sKlihTLgCfLVwAob2Gp/0X51Fck94rxBK1uELCwXXTb5DUAX8=
X-Received: by 2002:ab0:6486:: with SMTP id p6mr10992320uam.64.1550498517013;
 Mon, 18 Feb 2019 06:01:57 -0800 (PST)
MIME-Version: 1.0
From:   gy Lee <guguyayak@gmail.com>
Date:   Mon, 18 Feb 2019 22:01:46 +0800
Message-ID: <CAP9+kVAfSwkOAswGN3_OP6S3iaDoDq2HVq=wZccojMcq7hDC4g@mail.gmail.com>
Subject: echo rdma 20049 > /proc/fs/nfsd/portlist return Protocol not supported
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

hello!
    I am trying to configure NFS/RDMA for our infiniband network, and
following the instructions at nfs-rdma.txt.
    I installed the MLNX_OFED drivers on CentOS 7.5.
    I tested  infiniband network with tools like udaddy and
rdma_server/rdma_client and everything is fine.
    But when I execute "echo rdma 20049 > /proc/fs/nfsd/portlist",
show "-bash: echo: write error: Protocol not supported".
    I have searched a lot of information on Google and can't solve
this problem. I hope you can give me some help.
thank you very much=EF=BC=81

My test:
the server:
[rooot@w29 ~]# udaddy
the client:
[rooot@w28 ~]# udaddy -s 192.168.145.29
udaddy: starting client
udaddy: connecting
initiating data transfers
receiving data transfers
data transfers complete
test complete
return status 0

and the rdma_server/rdma_client
the client:
[rooot@w28 ~]#rdma_client -s 192.168.145.29
rdma_client: start
rdma_client: end 0
