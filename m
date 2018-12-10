Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A11DCC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 65A8220821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sh/QtBX4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65A8220821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728158AbeLJQ3W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:22 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37106 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727473AbeLJQ3V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:21 -0500
Received: by mail-it1-f195.google.com with SMTP id b5so19102314iti.2;
        Mon, 10 Dec 2018 08:29:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=NmLQ0+hGwH9bVgcJcPcLAmx+kXGyXl0FUA5aRyhgPj4=;
        b=sh/QtBX4S6XGUstt1bvTKrAlTTd2vQ8hzEdHQA8hAKVMVHqDsBsYbbEzGevVWMR2pa
         zPk6nvfzTOSQoUJdJMIwNCEcPUOWn0YL/AydRjhlC/1gxMDZn6bBJWHwuyIV1Y+VLSIn
         JcHgYkLxnosopaTmc8ND1zt+JJysr/WSdOGCQlQaZ++Ql4fTc0gLdzqq7XyhCBpIjJFK
         TSmXxfvRWteZYNGzog0zeTYhhpUKeTCIPZoQZNzEjVpy5rWD/Jir1ssgX1rOCk7iYNPh
         UJOz/jT/Kqs7qG/FEh7DJBCsSEIsW4tdSo1CJaVMVBpcUbe2BAmeeDyzKEBEjf69AT7V
         0Xcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=NmLQ0+hGwH9bVgcJcPcLAmx+kXGyXl0FUA5aRyhgPj4=;
        b=FoMkHyrdVIk5zbNeZLk4kw/wy5CmEQXLGT7WB2r/roqLsoV6LSymYig5Fokm0EY8SU
         ktNw/1H9uiCh20gZsTS4S/7iBvQtVOrQu0+750lQOpggVUp5a8sxO+4rLDgCGTpNa4WL
         4rk13G/c9B9ytN+G5vjZECl/NF1eI9QeleQpk/ekclwd4ereLQL5oCA5hRDxY26NBmOg
         EFN+A0Mnl/vrOPj6Tzf3aveOlJGdTwLbk02/egMlYl5coQRTw75rnnAeMGktrQQc1vge
         2zxnbQ5NRbFYCcoY+jxyh7oOKTHyFQ5LCz2XDlTctHyP5kobSr87Mswiw2F5nqG80O6R
         SDtg==
X-Gm-Message-State: AA+aEWaNFG/k3WJcMjN95iE/KfqLWtIUosm4iPfcV8X3UZq4xB/YpEi8
        DthhaZ870P1e8wQx6YygUzMVWHiv
X-Google-Smtp-Source: AFSGD/VvGHryJPWO1vEGcSGoUhX/CNR9ifPOLqwn6/CKQv1f9ScCuke0f0VoECmaYUv6RseO935MRw==
X-Received: by 2002:a02:b093:: with SMTP id v19mr12874373jah.64.1544459359832;
        Mon, 10 Dec 2018 08:29:19 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t10sm4812883ioi.4.2018.12.10.08.29.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:19 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTH2X031011;
        Mon, 10 Dec 2018 16:29:18 GMT
Subject: [PATCH v3 00/24] NFS/RDMA client for next
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:17 -0500
Message-ID: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Anna, I'd like to see these patches merged into next.

There have been several regressions related to the ->send_request
changes merged into v4.20. As a result, this series contains some
fixes and clean-ups that resulted from testing and close code
audit while working on those regressions.

The soft IRQ warnings and DMAR faults that I observed with krb5
flavors on NFS/RDMA are resolved by a prototype fix that delays
the xprt_wake_pending_tasks call at disconnect. This fix is not
ready yet and thus does not appear in this series.

However, use of Kerberos seems to trigger a lot of connection loss.
The dynamic rpcrdma_req allocation patches that were in this series
last time have been dropped because they made it even worse.

"xprtrdma: Prevent leak of rpcrdma_rep objects" is included in this
series for convenience. Please apply that to v4.20-rc. Thanks!

Changes since v2:
- Rebased on v4.20-rc6 to pick up recent fixes
- Patches related to "xprtrdma: Dynamically allocate rpcrdma_reqs"
  have been dropped
- A number of revisions of documenting comments have been added
- Several new trace points are introduced


Changes since v1:
- Rebased on v4.20-rc4
- Series includes the full set, not just the RDMA-related fixes
- "Plant XID..." has been improved, based on testing with rxe
- The required rxe driver fix is included for convenience
- "Fix ri_max_segs..." replaces a bogus one-line fix in v1
- The patch description for "Remove support for FMR" was updated

---

Chuck Lever (24):
      xprtrdma: Prevent leak of rpcrdma_rep objects
      IB/rxe: IB_WR_REG_MR does not capture MR's iova field
      xprtrdma: Remove support for FMR memory registration
      xprtrdma: Fix ri_max_segs and the result of ro_maxpages
      xprtrdma: Reduce max_frwr_depth
      xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
      xprtrdma: Recognize XDRBUF_SPARSE_PAGES
      xprtrdma: Remove request_module from backchannel
      xprtrdma: Expose transport header errors
      xprtrdma: Simplify locking that protects the rl_allreqs list
      xprtrdma: Cull dprintk() call sites
      xprtrdma: Clean up of xprtrdma chunk trace points
      xprtrdma: Relocate the xprtrdma_mr_map trace points
      xprtrdma: Add trace points for calls to transport switch methods
      NFS: Make "port=" mount option optional for RDMA mounts
      SUNRPC: Remove support for kerberos_v1
      SUNRPC: Fix some kernel doc complaints
      NFS: Fix NFSv4 symbolic trace point output
      SUNRPC: Simplify defining common RPC trace events
      xprtrdma: Trace mapping, alloc, and dereg failures
      xprtrdma: Update comments in frwr_op_send
      xprtrdma: Replace outdated comment for rpcrdma_ep_post
      xprtrdma: Add documenting comment for rpcrdma_buffer_destroy
      xprtrdma: Clarify comments in rpcrdma_ia_remove


 drivers/infiniband/sw/rxe/rxe_req.c      |    1 
 fs/nfs/nfs4trace.h                       |  456 +++++++++++++++++++++---------
 fs/nfs/super.c                           |   10 +
 include/linux/sunrpc/gss_krb5.h          |   39 ---
 include/linux/sunrpc/gss_krb5_enctypes.h |    2 
 include/trace/events/rpcrdma.h           |  216 +++++++++++++-
 include/trace/events/sunrpc.h            |  172 +++++------
 net/sunrpc/Kconfig                       |    3 
 net/sunrpc/auth_gss/Makefile             |    2 
 net/sunrpc/auth_gss/gss_krb5_crypto.c    |  423 ----------------------------
 net/sunrpc/auth_gss/gss_krb5_keys.c      |   53 ---
 net/sunrpc/auth_gss/gss_krb5_mech.c      |  278 ------------------
 net/sunrpc/auth_gss/gss_krb5_seal.c      |   73 -----
 net/sunrpc/auth_gss/gss_krb5_seqnum.c    |  164 -----------
 net/sunrpc/auth_gss/gss_krb5_unseal.c    |   80 -----
 net/sunrpc/auth_gss/gss_krb5_wrap.c      |  254 -----------------
 net/sunrpc/auth_gss/gss_mech_switch.c    |    2 
 net/sunrpc/backchannel_rqst.c            |    2 
 net/sunrpc/xprtmultipath.c               |    4 
 net/sunrpc/xprtrdma/Makefile             |    3 
 net/sunrpc/xprtrdma/backchannel.c        |   25 --
 net/sunrpc/xprtrdma/fmr_ops.c            |  337 ----------------------
 net/sunrpc/xprtrdma/frwr_ops.c           |   44 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c           |   47 ++-
 net/sunrpc/xprtrdma/transport.c          |   56 +---
 net/sunrpc/xprtrdma/verbs.c              |  107 +++----
 net/sunrpc/xprtrdma/xprt_rdma.h          |    9 -
 net/sunrpc/xprtsock.c                    |    2 
 28 files changed, 734 insertions(+), 2130 deletions(-)
 delete mode 100644 net/sunrpc/auth_gss/gss_krb5_seqnum.c
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

--
Chuck Lever
