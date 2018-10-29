Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2F77C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BEF772082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sesw1p4G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEF772082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727989AbeJ3Caj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:39 -0400
Received: from mail-qt1-f181.google.com ([209.85.160.181]:36604 "EHLO
        mail-qt1-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Caj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:39 -0400
Received: by mail-qt1-f181.google.com with SMTP id u34-v6so10244194qth.3;
        Mon, 29 Oct 2018 10:41:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=IgyDaZfwEUPZlkKF4y0uMUJUvT8fFpmSJbGW0wxf8QE=;
        b=Sesw1p4GP7HQ9Ohqcm8VbLQAMxcLCldqYQrhVBAgk/iA/QLSjm6BbgEfVrO47WH3vr
         15TlygPyrT1enQsXhAYsamqe3k4I4kZn+rZwkm+zvUKoJyENLBfI9HCXiVLqSTUYM7hk
         ECBkqzLl/TUjG9Ug/Lfge5baeROR/KiSPDFljKo6Rg+SlYJ0hot7zun4rY1klfyymLX9
         kIskwjrdNjnKv3XB0y5ALdMwIqY0waFglC62OAV91iBWjKxU98kTexZclV861decyNN5
         IolDd5EFT5dYhA0tx7+4vbfrniH2txB4tMLFFMbsKEMAKOJ3RW7DnXQotvyoNW8hbwfL
         nl7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=IgyDaZfwEUPZlkKF4y0uMUJUvT8fFpmSJbGW0wxf8QE=;
        b=AOsQT+ngNEXJJuNQneyUzxWgu2BGIKoAXLguzqj/L8EUzNrY/SjxVkqf1i6MqetObx
         VlmajdKPXpY0UXgRdlKcoVA9zqqH9Q2OzdxmhfvXqNBYIptq72T5pGoDeziz3AZcUVDx
         B6ChSsWo4l7hAX6NGLCrWEOK/wPde8jFeqR1poxZ2qD05XZa14BjEsk5AUdhCCR8F13T
         9gg9s5yMf+MT2C2SBXnRSfGt8QmCN3oNr3J7+nkTWMM1z1M9UFbxEbDUEm5+0O+pvEGI
         tBUCJPU8N/eYML/9O4jytKSCuxuXAR+ekLD2KCfxeQWq0Ao/9+AD+LHHgpuPFpjqw7eV
         dutg==
X-Gm-Message-State: AGRZ1gJd2vPyMZPwX6dzf/IMKaDQDtZ9rgSm9bkAbAFLK9eYVFeYG+cp
        NARuQMmn3H4PkjVPEYr87zM=
X-Google-Smtp-Source: AJdET5faohUWQFEOgjGatBjKL84D6EG2D1GiSoWKL5PMeu93/rcdEBSWEOiYcPCnjc3qdPQAWZZwQQ==
X-Received: by 2002:a0c:a043:: with SMTP id b61mr13903512qva.57.1540834861539;
        Mon, 29 Oct 2018 10:41:01 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.40.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:00 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 00/12] client-side support for "inter" SSC copy
Date:   Mon, 29 Oct 2018 13:40:46 -0400
Message-Id: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
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
represent an open.

Also this particular open is marked (NFS_SVC_SSC_COPY_STATE) so
that if the destination server ever to receive stateid errors on
this stateid, it knows not to initiate state recovery (in case
when source server reboots). The recovery must be done by the
client and a new copy must be initiated. Therefore, in this case
the recovery needs to fail with EIO.

v5:
-- in the VFS patches: 1. addressed use of file_inode, indentation,
2. Separated the cross-device checking relocation and ability to
fallback to do_splice_direct() into 2 patches. This NFS series has
only a requirement on the 1st VFS patch. 2nd VFS I propose as an
improvement but if it's deemed unnecessary, I'm OK with dropping
(I would need to change the man-page patch accordingly).
-- moved source offset check into NFS
-- reformatted NFS cross filesystem check to look better
-- I have added "Reviewed-by" to the commits but if I missed something
it was unintentional so please let me know.

Olga Kornievskaia (12):
  VFS: move cross device copy_file_range() check into filesystems
  VFS: generic cross-device copy_file_range() support for all
    filesystems
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
 fs/nfs/nfs4file.c                 | 127 ++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                 |   6 +-
 fs/nfs/nfs4state.c                |  14 +++
 fs/nfs/nfs4xdr.c                  |   1 +
 fs/overlayfs/file.c               |   3 +
 fs/read_write.c                   |   9 +-
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 16 files changed, 537 insertions(+), 25 deletions(-)

-- 
1.8.3.1

