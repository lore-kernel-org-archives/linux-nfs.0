Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E753ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4FEA720824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Wd68WZTO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FEA720824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727745AbeJ0EtX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:23 -0400
Received: from mail-qt1-f179.google.com ([209.85.160.179]:34353 "EHLO
        mail-qt1-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725965AbeJ0EtX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:23 -0400
Received: by mail-qt1-f179.google.com with SMTP id z2-v6so2705652qts.1;
        Fri, 26 Oct 2018 13:10:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=iZq+igXtd7B7yRB3A6SANShc1bYgK910waS8/hRhgtU=;
        b=Wd68WZTOTzgFiFmEnkY4kwgNkxYgfuTx9BjMA9KApR5QN5l3KonIP2QPHIj9eL/Bcf
         GOaeH2hQWfxMcbGjoDo1JmcwqzOjJnecgqITo6vj0y9xjDLQnHKBk5hsJYUiUBfuz8U1
         VGEqs30NIy+NynIoDtHRTcD8FNofYXA22jEcabcnCzRoNp82XpOJRgv9q1YHJ+tE3AAt
         6Ub4XR37N5tWwev9CQRNvTTKmb50hxtrwLnO6xvcX+hQG/2BKytTLg9q7uwqR5GrOJFA
         9GiutOtcbvmNKKp1revvF/0uz0gq5nhVeMHEZQ5FVJQ5MLtUKk+8kDrQMbH5mQpVxlAO
         vYIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=iZq+igXtd7B7yRB3A6SANShc1bYgK910waS8/hRhgtU=;
        b=P1mPr6YsxR0Oeqw/rA60SRZHv2X1vMxk3IvK1pyqCyu9cMtyUFy5tZI0Veb/mtNS17
         CU7aDu73xZpCBqb2zmQgYkSbX+VqnDF8xMmrF/7u3/zpIAw5ZKui7BCsaHbr1g1a6gUp
         FBessXLaAyLewxgsPmjLZ+ZJuiMHS1Q3hk0p1GyQwpIXZBxEFWYqxymMk9jGCSc5Flus
         dAxPiscjggEw2ym2uVl+/Exwlyn6ML7HkHtZGMHvNfl9aPW2QQEfnzLfe8Nwr9Ql5mvH
         xhCezOAd0Ju2OfLx/1H67ZLZwPMpqTRi6AW2Ym9vMJfKPb69tWXDiYQ2A4Z7O5piHcp6
         nw5Q==
X-Gm-Message-State: AGRZ1gLCkzxNgE7f2J1n+tXS4Ft4QQKzLV7ScxmlWge+DTeVgxIuwb+2
        TC0VVXbqYQc4gShdjkKwf4U=
X-Google-Smtp-Source: AJdET5ceju7o+YGSh5H33h81Zd4BLv2Czky6Hhtkq9Ms04dOr7Nzb/nrrahCtDhegM0mfqdvwrVUgw==
X-Received: by 2002:aed:39a9:: with SMTP id m38-v6mr4701551qte.222.1540584659501;
        Fri, 26 Oct 2018 13:10:59 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.10.58
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:10:58 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 00/11] client-side support for "inter" SSC copy
Date:   Fri, 26 Oct 2018 16:10:45 -0400
Message-Id: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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

v4:
-- in the VFS patches: 1. removed the accidental text in vfs.txt,
2. removed additions to vfs.txt, and 3. Anna provided help with 
wording the commit message and 4. changed the offset check to
include the boundry just like it was before.
-- removed dprintk from the nfs42_ssc_open
-- changed the cross filesystem check in NFS's copy_file_range

Olga Kornievskaia (11):
  VFS move cross device copy_file_range() check into filesystems
  VFS copy_file_range check validity of input source offset
  NFS NFSD defining nl4_servers structure needed by both
  NFS add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY
  NFS also send OFFLOAD_CANCEL to source server
  NFS inter ssc open
  NFS skip recovery of copy open on dest server
  NFS for "inter" copy treat ESTALE as ENOTSUPP
  NFS COPY handle ERR_OFFLOAD_DENIED
  NFS replace cross device check in copy_file_range

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
 fs/read_write.c                   |  12 +--
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 16 files changed, 538 insertions(+), 25 deletions(-)

-- 
1.8.3.1

