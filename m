Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB3AC6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C62162080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qP8wDjg1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C62162080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727851AbeJaFv3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:29 -0400
Received: from mail-qt1-f180.google.com ([209.85.160.180]:44878 "EHLO
        mail-qt1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726005AbeJaFv2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:28 -0400
Received: by mail-qt1-f180.google.com with SMTP id b22-v6so15240806qtr.11;
        Tue, 30 Oct 2018 13:56:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=iFhpr+k22rUFc5Hamw6OQ9VnUSFg3SNNscx1AQwxDls=;
        b=qP8wDjg1GtuOioRVKOe4JoTv5UlqueUl82ctbnl1xHrbWZZb/g44HFRdpyzsr4QzcD
         3cTgJfjftiT/TfuqkW+QaDslTIBHEIwEXS81zXDmUnveGgnecUgwUi+FtYnHH0EiGhDQ
         53knm7RGpqOHHtT10Pp+PHYKlrFSoeyWGuhndnW5MSa6rH0ph8mBySznyu4eDg5SjRfd
         QmNYkj+/5xK+FIPAtOqS1M03pZT6ZcvlXvrBhozblXaym/qQJXzFBoTtuq3QocK5GzMK
         c0n/JrO/yJ9S1iKF6srfgjMZsQQEth5GhYvkvcRkoSkad+vbFxfPmq5ZfG2ZBRRahhGg
         vvIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=iFhpr+k22rUFc5Hamw6OQ9VnUSFg3SNNscx1AQwxDls=;
        b=rF+IAofaWKA00IzsNCYf4Kc3w5N+T28T/m1r93T1XIAqVAopRW7wh3zwuOtLP+Jxt1
         BeHTteCPbWnbnXIMyQRddoGFfDAQawwBRyB1TV+8nOLBQeMU0zNtiiVhPdRhnZsCifQb
         URsl3PkcfKRShCKjnvbmMOZgtIHzj1l/lssppePSHo/xUwNjh4fFI+yyRe1UdEknDiPb
         DaN0h58nJ6Di+EgMZrOAabUJMHXyss40Z3vQgaLXl1IEVykt6LLmGE3C8iNx1clUxzZ3
         b9TZY0pV1NJ0yeirHS3NLDLjcwbJ+KkGFz3KRwusK0RmMZ7R7zCSRAw315djiZ3gVszF
         50uQ==
X-Gm-Message-State: AGRZ1gIlWBHANpc7pn5UhN8EPa42oP1ZD+WDba0DJnsGigNzc0FSBdSH
        5xH8uAAzpDLzuAqv5TEorHQ=
X-Google-Smtp-Source: AJdET5dJMBzbkIqkamRIzZMWGjDhzs9TG9zJPFzLOF4hg1tFXtw6P1mD3SQqnv1cYdUEzUuEyfPSmw==
X-Received: by 2002:ac8:4419:: with SMTP id j25-v6mr271582qtn.243.1540932984438;
        Tue, 30 Oct 2018 13:56:24 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.22
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:23 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 00/11] client-side support for "inter" SSC copy
Date:   Tue, 30 Oct 2018 16:56:02 -0400
Message-Id: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

This patch series adds client-side support for doing NFSv4.2 "inter"
copy offload between different NFS servers.

In case of the "inter" SSC copy files reside on different servers and
thus under different superblocks and require that VFS removes the
restriction that src and dst files must be on the same superblock.

NFS's copy_file_range() determines if the copy is "intra" or "inter"
and for "inter" it sends the COPY_NOTIFY to the source server. Then,
it would send of an asynchronous COPY to the destination server. If
an application cancels an in-flight COPY, OFFLOAD_CANCEL is sent to
both of the servers.

This patch series also include necessary client-side additions that
are performed by the destination server. The server needs an NFS
open that represents a source file without doing an actual open.
Two function nfs42_ssc_open/nfs42_ssc_close() are introduced to
accomplish it that make use of the VFS's alloc_file_pseudo() to

v7:
--- in VFS patch: remove the support for generic copy_file_range
for all file systems, just allow for individual filesystems to
support cross device copy_file_range. the check for the superblocks
is moved just before the do_splice_direct()
--- modified the man page

Olga Kornievskaia (11):
  VFS: move cross device copy_file_range() check into filesystems
  NFS: validity check for source offset in copy_file_range
  NFS NFSD: defining nl4_servers structure needed by both
  NFS: add COPY_NOTIFY operation
  NFS: add ca_source_server<> to COPY
  NFS: also send OFFLOAD_CANCEL to source server
  NFS: inter ssc open
  NFS: skip recovery of copy open on dest server
  NFS: for "inter" copy treat ESTALE as ENOTSUPP
  NFS: COPY handle ERR_OFFLOAD_DENIED
  NFS: replace cross device check in copy_file_range

 Documentation/filesystems/porting |   7 ++
 fs/cifs/cifsfs.c                  |   3 +
 fs/nfs/nfs42.h                    |  15 ++-
 fs/nfs/nfs42proc.c                | 129 ++++++++++++++++++++++---
 fs/nfs/nfs42xdr.c                 | 193 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h                  |  10 ++
 fs/nfs/nfs4client.c               |   2 +-
 fs/nfs/nfs4file.c                 | 125 +++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                 |   6 +-
 fs/nfs/nfs4state.c                |  14 +++
 fs/nfs/nfs4xdr.c                  |   1 +
 fs/overlayfs/file.c               |   3 +
 fs/read_write.c                   |  12 ++-
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 16 files changed, 539 insertions(+), 24 deletions(-)

-- 
1.8.3.1

