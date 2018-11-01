Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BFEBC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7424205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XToKnxWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7424205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726318AbeKBBtM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:12 -0400
Received: from mail-oi1-f174.google.com ([209.85.167.174]:36663 "EHLO
        mail-oi1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725959AbeKBBtM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:12 -0400
Received: by mail-oi1-f174.google.com with SMTP id r127-v6so15412716oie.3;
        Thu, 01 Nov 2018 09:45:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=XxnJuC4seBqE3SitWnE6J99mpR7VK8QhZfW7nenLvkY=;
        b=XToKnxWd/HZk/Hmeps1G+99axXuUXDELyh5VS98gNfq9m8Hue87Gdr8RJ9d2iP7mks
         QJjFSTUrtx68Dd7I1oh5W3ycOKgyyvAi8RhuMydaPHV5t20AzS9srn/8apmf0uoR3K+8
         2Las9/w+uIsH4Wn/XgXIT/I7ClG+6ZAfh+pEKfn8aDUAMUgTAuDgJmhuVo+XGFmCTllS
         m/SBBHd2LqGcyZ2OsBq/wONdZg8h1bnr9IL7yI3Noms7e/O3aFcDS583NsD1kMYPl/bh
         /eBT+n8kpgaxafJQXxFBQRXcwQRbo+5y9OceAhaX8C7XR91a0lmTrSJUgtD5jLUnrpqo
         XY/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=XxnJuC4seBqE3SitWnE6J99mpR7VK8QhZfW7nenLvkY=;
        b=JxfTZdzSqIqjB2RiDzOgpLeuf1/w5kpjowhY2Nep5aVlYrKWpmBHEYS+53TTiMUXPk
         nmWRwhtVY+Trxw15OsYWzbxVWHhTCv8a0bh9WE/Aph4TalDhpqbD0xtiqOICUgqGOvAm
         3AF2hiKqMqscsHQ7Gx9KiaaTSFhugPNiQprtGFU6fAMQlb2DLqlhNkZHSyDTv7NYBNdL
         rIHrycfdJeQ5j7xpnkimTkeBqcceiPjrL8JdN5QANRn9FIVVtj/NEspEgEtViV7d0g+O
         FtHnq//G6Okb+/mBBRwSZdWhJ/lqhmzK0kCSHvVNES2VWRhGbW4wB4CNKjOT0XXDJ3Ed
         gV3A==
X-Gm-Message-State: AGRZ1gIlop42u9f9g9iFFKhRvJgSR3v9rHlcBpQPtjxH2jqZqtUaU5R8
        c2ppbCnVhuvc4dAyu+g3W4U=
X-Google-Smtp-Source: AJdET5dZb3MFxb0/W9vyn6l+vMrTB6J9x3HBy0bwB/reQYAk5G8s1ttrugYqKWR+1++32vOLSZGr4g==
X-Received: by 2002:aca:dfc3:: with SMTP id w186-v6mr4991796oig.331.1541090726965;
        Thu, 01 Nov 2018 09:45:26 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.25
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:25 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 00/11] client-side support for "inter" SSC copy
Date:   Thu,  1 Nov 2018 12:45:12 -0400
Message-Id: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
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

v8:
--- in VFS added a comment about the superblock check to be removed
once the future VFS work in copy_file_range happens
--- Fixing copy_notify patch to check that server is capable of
doing copy_offload, preventing an oops on an 4.0 mount trying to
use copy offload. As the result, the last patch that replaces
cross device check for NFS, only needs to check for the fs type.
--- modified the commit message for the NFS source offet validity check
to document why we are doing the check as per Bruce's comments.

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
 fs/read_write.c                   |  13 ++-
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 16 files changed, 540 insertions(+), 24 deletions(-)

-- 
1.8.3.1

