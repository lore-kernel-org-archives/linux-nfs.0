Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419FAC10F03
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 107192085A
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uzwdn9ei"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726311AbfCGP2m (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:28:42 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:36068 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726207AbfCGP2m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:28:42 -0500
Received: by mail-it1-f194.google.com with SMTP id v83so16394385itf.1;
        Thu, 07 Mar 2019 07:28:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=ytFn4gtJbVK7BZovKxprUx8LCj9qJPAX8GdGlqlR93A=;
        b=Uzwdn9ei5BGoLI8+GYcOuVhjh2SinzX1+tzBtGaOaS1JVPJR0IvjGNgVsis3lT/Oa8
         60vP1dgUbq34n5NG2ZWTXKOy8mCXHAqK7RK23Mk07synVZ2IUFEH34wZl70QKaYytOe9
         hYpdXXsV1PwKTwqUFfaDZ+yL5z7yaWciMWCr0D5YVB25pw1telMqCnP3MDLQ4MRru465
         f1Rf2Piq7bKHc8z5tAD1t6kOXvRDeqyGOukeLcu1xAbB6zRlrDMVwkum9FUosgesMV9/
         nAjh7x8Du6n7+lBl9KCJ95uSf0QTiyQzk7d42Ukm8aZvLDPK16MOykqkO/1lOjUvBFjy
         jARw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=ytFn4gtJbVK7BZovKxprUx8LCj9qJPAX8GdGlqlR93A=;
        b=GL4xH7TW8xsetLZf1KjbKnNhUh2kaMBDUcR2WXGyafZ+ksP3J0ZjRGvFEm2QHPvKcb
         +3WofF/jc0haDlk6WjJW1vtorfLygZzQrJm0gRgpwsNpuvBJ3a1wY/askGTXAsfRRYNY
         LpTSO6QEvunLOIVQoJ9hyjNSm54uamiBokJuH+Wr+dUn+WLrhC4xRz0/VM++85RWAIJc
         DtEFmzm7Tib/Wa6fC43VQoV7FVLLBHHHleuFw8uiWTRdjymfD+NqR3je2Bqqd3PB3QOR
         rUU1MTPMl66ctlKjSwNGEk7gkLknJOVnFlSRjFNLbW/ixf6KmiS2wIE4yUJs1Id96C5t
         bfVA==
X-Gm-Message-State: APjAAAU4pDfzF7JFP1IlvAaSYbfTIYSIB/WN/QiokxX8HErTisGU4bC7
        ESFFPgoa09F3xWg5fj3A/2XSo42w
X-Google-Smtp-Source: APXvYqywEPobpk7yWk2807WASyXZdDoQP/u1Mqq92O4nC7mI2QMTYC8q4mxa3c+8pe/52K51LnhWww==
X-Received: by 2002:a24:9982:: with SMTP id a124mr5435212ite.79.1551972520306;
        Thu, 07 Mar 2019 07:28:40 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u18sm2063945ioc.64.2019.03.07.07.28.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:28:39 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FScfm007215;
        Thu, 7 Mar 2019 15:28:38 GMT
Subject: [PATCH v2 0/5] RFC: Linux IMA on NFS prototype
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:28:38 -0500
Message-ID: <20190307151838.11306.94183.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This series implements support for accessing and updating the
security.ima xattr on files that reside on an NFS export. Since the
NFS protocol does not have capabilities like CAP_SYS_ADMIN, on NFS
clients, only root is allowed to set this xattr.

I'm interested in comments on the implementation, test results, or a
discussion of whether this proposal creates undesirable security
exposures.

Git repo: git://git.linux-nfs.org/projects/cel/cel-2.6.git

in the nfs-ima-prototype topic branch.


Implementation Notes

Please see the individual patch descriptions: standards action is
still required to define the official FATTR4 flag that all NFSv4.2
implementations recognize as meaning "the security.ima xattr". This
prototype is not guaranteed to interoperate with future prototypes
or standards-compliant implementations of this feature. It is for
experimental purposes only.

EVM is not supported in this prototype. The NFS protocol does not
support several of the xattrs that are protected by EVM: SMACK64,
Posix ACLs, and Linux file capabilities are not supported. When
these are present in an EVM hash, NFS clients can't retrieve them
to verify the hash.

This prototype does not match what is described in draft-ietf-nfsv4-
integrity-measurement. Since that draft was submitted, there has
been vigorous discussion on nfsv4@ietf.org about how the NFS
protocol should support Linux IMA. The prototype attempts a narrow
interpretation of what the comments have requested. The draft will
be updated to reflect the prototype implementation.


Changes since v1:
- Rebased on kernel v5.0
- Moved NFSD support out from behind CONFIG_NFSD_V4_SECURITY_LABELS
- Added a patch to remove ima_file_check call in NFSD

---

Chuck Lever (5):
      NFS: Define common IMA-related protocol elements
      NFSD: Prototype support for IMA on NFS (server)
      NFSD: Remove ima_file_check call
      NFS: Rename security xattr handler
      NFS: Prototype support for IMA on NFS (client)


 fs/nfs/nfs4_fs.h          |    1 
 fs/nfs/nfs4proc.c         |  134 +++++++++++++++++++++++++++++---
 fs/nfs/nfs4xdr.c          |  186 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c        |    9 ++
 fs/nfsd/nfs4xdr.c         |   49 ++++++++++--
 fs/nfsd/nfsd.h            |    3 -
 fs/nfsd/vfs.c             |   25 +++++-
 fs/nfsd/vfs.h             |    3 +
 fs/nfsd/xdr4.h            |    3 +
 fs/xattr.c                |   25 +++---
 include/linux/nfs4.h      |    5 +
 include/linux/nfs_fs_sb.h |    1 
 include/linux/nfs_xdr.h   |   21 +++++
 13 files changed, 426 insertions(+), 39 deletions(-)

--
Chuck Lever
