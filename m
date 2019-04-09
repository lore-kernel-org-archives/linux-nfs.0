Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DA50C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E0FD2084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IhBrjQE4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726471AbfDIPs2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:28 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:54375 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfDIPs2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:28 -0400
Received: by mail-it1-f196.google.com with SMTP id a190so5681146ite.4
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lkggeyYJ4rYWkt5kAiGmY+rawfkkeeoWjCVBeQTB3TU=;
        b=IhBrjQE4KZr5E/N1nP0A+1t+hsWEoFzpsXcsy0/Ixcjf/OxFkBh8nPtpmXMup37ebc
         A53zT2l7Rm4X7KbtN34AW8lJinCvcPcSMUJlYMjUkJHoQQPCH7cYHk8DDa0cwnYsr28r
         SsbNGTEPSUC5eC7+J56hnxQpn7I60fwq8ILl2x7/k379SqykbAfoHzEl/gqmDJMyxFO/
         Go7xx75DfVT/MRXDf4APJck67X/BP2GJUqeOdXhZdrGQUeyA61wyiL8FsUkSqXm/k2FQ
         DTwc1cQJTsstkePBG/wqoGivLqhsxjFSs5r210L4w0FOszB/jeTmVuq23+7pp/xIW0MK
         IZxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lkggeyYJ4rYWkt5kAiGmY+rawfkkeeoWjCVBeQTB3TU=;
        b=bCAL90z9NUGsUFRFufbZfFWaygy39QSpM6x6JqEAeW6IwdflNAv0GjhRTmf2g/vEBz
         0iB5pYODxSHss+qRuRFcXCwAHrWKJTdkDJfMULsuBXUzEWn8FrGn9YNP4X5kwNtMgjy3
         GbFdCYpume9QMiNKDMiOKpsvQqpdudYxx2P4cTx9LizXxIfrzZK9VZ9G6LiJBIBfMrVx
         fdNeIueAXMFHEpxrDuuInV2lQVieFoTh1JWwyzOHgHpuN/nehNzqBatVmwfz8EV7mMrI
         um+n6PJ42roJAsarHEPLCsodlKF7Tegtm1UqCGJJ1YssOXXLOau3zDEJsKB8UIE6dfmj
         HqLg==
X-Gm-Message-State: APjAAAXYWgigDperQ23I56lAJ3yxyuITMEAbrZYP7EkOR+2YZGMgQPo2
        sadbqG2U/2xA24CXcySVEn8Rr0s=
X-Google-Smtp-Source: APXvYqzJhri1zYi1k1yNXYQrvvCmA9I+1hC0maJOdWJBvRMaxEa8gLlR3klYUxqa9ZmBJ1j+to/50Q==
X-Received: by 2002:a02:b60b:: with SMTP id h11mr26374916jam.125.1554824907540;
        Tue, 09 Apr 2019 08:48:27 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:26 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] Allow containerised knfsd to set supported NFS versions
Date:   Tue,  9 Apr 2019 11:46:13 -0400
Message-Id: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The current knfsd implementation is unable to support containers that
want to run different combinations of NFS versions. This is because of
the way we define which versions are supported: by directly editing the
global version table in 'nfsd_program'.
The following patch set modifies the method used to define version
information by moving some of the server RPC request initialisation
down into knfsd itself, allowing it to manage the version-specific
initialisation.

Note that we might want to consider a few follow ups to this patchset
to get rid of some of the version-specific flags (e.g. vs_hidden) that
currently need to be managed in the generic SUNRPC server code on behalf
of just one or two RPC programs. These flags can easily by replaced by
custom RPC request initialisers.

---
v2: Fix compile issues when CONFIG_NFSD_V2_ACL and CONFIG_NFSD_V3_ACL
    are undefined.
    Don't move the svc_reserve() call in svc_process_common(), since
    that can trigger 'RPC request reserved xxx but used yyy' issues.


Trond Myklebust (6):
  SUNRPC/nfs: Fix return value for nfs4_callback_compound()
  SUNRPC: Add a callback to initialise server requests
  SUNRPC: Clean up generic dispatcher code
  SUNRPC: Allow further customisation of RPC program registration
  nfsd: Add custom rpcbind callbacks for knfsd
  nfsd: Allow containers to set supported nfs versions

 fs/lockd/svc.c             |   4 +-
 fs/nfs/callback.c          |   2 +
 fs/nfs/callback_xdr.c      |   2 +-
 fs/nfsd/netns.h            |   8 +
 fs/nfsd/nfs4proc.c         |   3 +-
 fs/nfsd/nfsctl.c           |  25 ++--
 fs/nfsd/nfsd.h             |   8 +-
 fs/nfsd/nfssvc.c           | 255 +++++++++++++++++++++++++------
 include/linux/sunrpc/svc.h |  33 ++++
 net/sunrpc/svc.c           | 298 ++++++++++++++++++++++++-------------
 10 files changed, 478 insertions(+), 160 deletions(-)

-- 
2.20.1

