Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56D38C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:05:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0A45620672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:05:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hVL6WZim"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A45620672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726363AbeK0HBE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:04 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:50203 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:04 -0500
Received: by mail-it1-f196.google.com with SMTP id z7so12818264iti.0;
        Mon, 26 Nov 2018 12:05:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=fz6asWs6nmS4qvozKwnyWw4oTNhs6zeyzilGOWtxZ3s=;
        b=hVL6WZimMl3h81J/t8Us8RgaB88U45bI3VJF5NLZGrqw6EN7mtydyW5dGN4x1+gZqc
         rQKoq8B/EZ4xMwKfSlPQVBTM9TwgbBaMn+u3KQGkLcpQclbuyMx80T6NB32NgCbGJ+s+
         L/tuiwqqutbyMzDvc92pKi3LyRCQds0ppjK7UIZIihjkTW80Av6uXB1aF7smXoT1oUH8
         yPAYs/MIG2kFGHfk7sHADoMQvGi3Fp1ytPMd47vSANpjL6CUKVPLwh4iqbs83qxER7QO
         SCHoljPNIbMt4bjLrFDlsguCSc+sj2/464Jq4x0HNlsGHIGSePP/99E1Ju8ZLK8uQP5i
         2/6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=fz6asWs6nmS4qvozKwnyWw4oTNhs6zeyzilGOWtxZ3s=;
        b=erwh1eYmHfMzoph6Bmj+dag8NOUj05yy/G3xOYQKG9Kgz1dmgC0bLyt3WzTFpaDWVw
         7MwI0tbxyHI0BQZI+cf+CTGobdCVWJSe+s7iHL28DqUISlo2HEM4AlB9MoAxpDXepPV4
         ECst2UQdHfOG0hFgb5RwkKlgQKM7pZ4pFGkvuoQvhmh0P4ifyyzF9nqoRTPd+Z/wUM60
         zPF6Y9ZwPDIrsIRIQrmsOv2iWS7p+84I7vmKUD+Pk6pdcwBOrN7NXa9rFOBrXDGK4beN
         ihy6RMhfbQhRbpWmlUgZIYZ6SYUG61+lumh4jSMczQoLzW76038wRfPpQkQUj5dWJmr3
         x5Sg==
X-Gm-Message-State: AA+aEWb7E0Bbtwy2qOdWBbTdCtJH6TTynwMrCeLdwIneHfgBlWnXvjRE
        B+IOR7ZwaQcsF0wpXFDja/Y4a3fA
X-Google-Smtp-Source: AFSGD/W72csSx2Ci3IpcpfW7zxhejIbB7vJMSSYOKhaXlmF3VljKaWKLMbJCFAgdVAbxYTqH/xgYGg==
X-Received: by 2002:a05:660c:344:: with SMTP id b4mr3508144itl.51.1543262749245;
        Mon, 26 Nov 2018 12:05:49 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u126sm635746ita.1.2018.11.26.12.05.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:05:48 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK5kXa010641;
        Mon, 26 Nov 2018 20:05:46 GMT
Subject: [PATCH v2 00/20] NFS/RDMA client for next (complete)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:05:46 -0500
Message-ID: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi, I'd like to see these patches merged into v4.21. I'm posting
here for review. This is the second version of the series I posted
last week.

Changes since v1:
- Rebased on v4.20-rc4
- Series includes the full set, not just the RDMA-related fixes
- "Plant XID..." has been improved, based on testing with rxe
- The required rxe driver fix is included for convenience
- "Fix ri_max_segs..." replaces a bogus one-line fix in v1
- The patch description for "Remove support for FMR" was updated

NFS folks, I'm especially interested in your thoughts about two
of these patches:
   NFS: Make "port=" mount option optional for RDMA mounts
   SUNRPC: Remove support for kerberos_v1

---

Chuck Lever (20):
      rxe: IB_WR_REG_MR does not capture MR's iova field
      xprtrdma: Remove support for FMR memory registration
      xprtrdma: Fix ri_max_segs and the result of ro_maxpages
      xprtrdma: Reduce max_frwr_depth
      xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
      xprtrdma: Recognize XDRBUF_SPARSE_PAGES
      xprtrdma: Remove request_module from backchannel
      xprtrdma: Expose transport header errors
      xprtrdma: Simplify locking that protects the rl_allreqs list
      xprtrdma: Refactor rpcrdma_create_req()
      xprtrdma: Prevent req creation while unloading the underlying device
      xprtrdma: Dynamically allocate rpcrdma_reqs
      xprtrdma: Cull dprintk() call sites
      xprtrdma: Clean up of xprtrdma chunk trace points
      xprtrdma: Relocate the xprtrdma_mr_map trace points
      NFS: Make "port=" mount option optional for RDMA mounts
      SUNRPC: Remove support for kerberos_v1
      SUNRPC: Fix some kernel doc complaints
      NFS: Fix NFSv4 symbolic trace point output
      SUNRPC: Simplify defining common RPC trace events


 drivers/infiniband/sw/rxe/rxe_req.c      |    1 
 fs/nfs/nfs4trace.h                       |  456 +++++++++++++++++++++---------
 fs/nfs/super.c                           |   10 +
 include/linux/sunrpc/gss_krb5.h          |   39 ---
 include/linux/sunrpc/gss_krb5_enctypes.h |    2 
 include/trace/events/rpcrdma.h           |   42 ++-
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
 net/sunrpc/xprtrdma/backchannel.c        |   31 --
 net/sunrpc/xprtrdma/fmr_ops.c            |  337 ----------------------
 net/sunrpc/xprtrdma/frwr_ops.c           |   28 +-
 net/sunrpc/xprtrdma/rpc_rdma.c           |   41 +--
 net/sunrpc/xprtrdma/transport.c          |   44 +--
 net/sunrpc/xprtrdma/verbs.c              |  129 ++++----
 net/sunrpc/xprtrdma/xprt_rdma.h          |   12 -
 net/sunrpc/xprtsock.c                    |    2 
 28 files changed, 561 insertions(+), 2126 deletions(-)
 delete mode 100644 net/sunrpc/auth_gss/gss_krb5_seqnum.c
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

--
Chuck Lever
