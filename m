Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26EA0C10F05
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8BBB21B68
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 20:43:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lRn7ytDy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390196AbfBNUnI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 15:43:08 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:38102 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389444AbfBNUnI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 15:43:08 -0500
Received: by mail-it1-f195.google.com with SMTP id l66so7747274itg.3;
        Thu, 14 Feb 2019 12:43:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=ywj50zLLmbe5uxXqlccyrFee1766tyo4QskRCN7gUPo=;
        b=lRn7ytDyvlAUhPie6mLZCm4LtC2UkF5qd5EXvDT/sV8Z3A11GPc6ks8TdXqMpUA9ih
         J6uSjmwpUHjvw8XCLVk9cJG0PiAxzk9twT1Bt6wdjdrWqjfuDepvvt821NwfaReD5Sbs
         pjgWdef0Z5xMvrrqWgaOXu9upjNSBPlwTCNpZpY8iqdrQAVrgrdOlcT1J50bltGinaAv
         shXtx7SwQjmm/v9TOM454UoWtzb8qDKBKvZInA2Aqeh/XcOhj5/fsEQjOo5emSCk+vbP
         VfM72vY6I1OykV4g6vQuQ+xgdKLOVBxU33MM7rbyeS1nwE1vHWNKfebZ19H8cooVJbfz
         xPBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=ywj50zLLmbe5uxXqlccyrFee1766tyo4QskRCN7gUPo=;
        b=p7UVsSacA0QG4C137VDpH/1oQnJA1fi2TpDewNN0OwhxOG2uYOi1ZPTd/oQ932B+Kp
         2VtzNg0peT/FtcC16Y8SWPobQhekaWmGDAyqkJMBhbuhGEfo9/48QXUCwzHyA2ggC6WB
         8zoFvBhx4iDcwvCZNmxzp0+mYFsw/T+Dh7ruUMu1I6hABYoAsXl8L7Iyo7PnXTHNvo8e
         rY8KW5Pe+RkOZnjFNGa/CShRXKL4d61nzNTNA8gMyMiK8H7UfcNO9FziP7uFWQYmYOmG
         yL1sGnQ6OB2uHfAYx6YZ4fhgqwRheVC43L1w5nttMSqofe5hsqoimZGSi/WWvjl/dnBY
         hFsA==
X-Gm-Message-State: AHQUAuZ942UJgiXdqPynJsuvBoXmqzLar7Mqj1hFJ599oCq8ACvFSHc4
        vH+/eVuLZyrSYhIkzzFdzqy8VOKv
X-Google-Smtp-Source: AHgI3IbMY8s3f8fhzZCq1olyGCgq8QElkfScAkqEftI9rz+UiJ/WE/K4+Q4HhdLHpFlaNJDUWRATdg==
X-Received: by 2002:a24:14e:: with SMTP id 75mr3499722itk.44.1550176987118;
        Thu, 14 Feb 2019 12:43:07 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w67sm2392778itw.38.2019.02.14.12.43.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:43:06 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1EKh5rR006552;
        Thu, 14 Feb 2019 20:43:05 GMT
Subject: [PATCH RFC 0/4] IMA on NFS prototype
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 14 Feb 2019 15:43:05 -0500
Message-ID: <20190214203336.6469.34750.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This series implements support for accessing and updating the
security.ima xattr on files that reside on an NFS mount. Since NFS
does not have CAP_SYS_ADMIN, only root is allowed to set this xattr
(on clients or on the server).

EVM is not supported in this prototype. NFS does not support several
of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
Linux file capabilities are not supported, which makes EVM more
difficult to support on NFS mounts.

Please see the individual patch descriptions: standards action is
still required to define the official FATTR4 flag that all NFSv4.2
implementations recognize as meaning "the security.ima xattr". This
prototype is not guaranteed to interoperate with future prototypes
or standards-compliant implementations of this feature. It is for
experimental purposes only.

I'm interested in comments on the implementation, test results, or a
discussion of whether this proposal creates undesirable security
exposures.

A topic branch with this work is here:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

in the nfs-ima-prototype topic branch.

---

Chuck Lever (4):
      NFS: Define common IMA-related protocol elements
      NFS: Rename security xattr handler
      NFS: Prototype support for IMA on NFS (client)
      NFSD: Prototype support for IMA on NFS (server)


 fs/nfs/nfs4_fs.h          |    1 
 fs/nfs/nfs4proc.c         |  138 ++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4xdr.c          |  175 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c        |   15 ++++
 fs/nfsd/nfs4xdr.c         |   54 ++++++++++++--
 fs/nfsd/nfsd.h            |   10 +++
 fs/nfsd/vfs.c             |   32 ++++++++
 fs/nfsd/vfs.h             |    3 +
 fs/nfsd/xdr4.h            |    3 +
 fs/xattr.c                |    3 +
 include/linux/nfs4.h      |    5 +
 include/linux/nfs_fs_sb.h |    1 
 include/linux/nfs_xdr.h   |   21 +++++
 13 files changed, 440 insertions(+), 21 deletions(-)

--
Chuck Lever
