Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0900ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6134F20832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jo7CMMAm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6134F20832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726365AbeJYE2I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:08 -0400
Received: from mail-qt1-f175.google.com ([209.85.160.175]:43226 "EHLO
        mail-qt1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726221AbeJYE2H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:07 -0400
Received: by mail-qt1-f175.google.com with SMTP id q41-v6so7084273qtq.10;
        Wed, 24 Oct 2018 12:58:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=yZoCFXWFitT78bFJsf/NaKp93I9MAv0I1ZvlCXLJe7c=;
        b=Jo7CMMAmupSN44a2Zw6w1S4cbCAnXaZQbwtvxhTfvCE38Y+cvBCYEflU/KpU705eXG
         vt4c2eXuflaHe0wlTai/lh5eyutdKWfeBH0Q7cFNXpLjIEPskGYavQTjS84abHvJndjD
         oeHhf80qSTRVNp+cRDshPYwn8uK8woNd+MSDQlFE6qihIGTvPBmdGRzhQE65upiZQhqv
         nccHZZSfgLTXQCMqq2EPiL+sDhapkiljP7d92cZgOId+117Nw+ehtnLTfa9vOMXsHOMf
         HES3CVUyKGLuHRGcLmW3USznPIHg8dQtgKfGSXgbUNszQBN//bdqmicUB1Lea9ZxoLPE
         5ASg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=yZoCFXWFitT78bFJsf/NaKp93I9MAv0I1ZvlCXLJe7c=;
        b=BWxrvQzjS7VkBVAzzYSzFXPrzKZOD+U6Y48ns7SxlLtoMX3zZxGGiE+SGk11SFBSsw
         KPQVpDjgDmyx0ELeuPOYiBz64TWTj6RG1qwCbIylhiRJZwSe/hqI1Fwao0dTAkb9NRmj
         iUkKLy6+Mby+ycJf4/ZjaWMNsTiQvHcKfQcdGqUqfpUhOpwkPr+qhUW+NoAIUuNf8Pbr
         Lp2AAEK86wzIQ41PZhk4R4Je7ByczHslTmbf6V/oLibG1iHikQ3VlJS/Ix8z5bKusLXT
         IllhTICrzrmZ6qIAWPPzrqr44/JA6tR6R5xTF3KOo33dO+NKZXCY3jzaUuABDskpE+Wb
         kbhQ==
X-Gm-Message-State: AGRZ1gI5Xo2HBKv5vPbWBFHdEOdzEDNbmfMzdKTYK4ETYp3ld7RePEGC
        JPEIUmR+tN1ckBsE0bUZsN8=
X-Google-Smtp-Source: AJdET5fwmM8a2ZOERG1wyTEw/j/hXqKBvOI/nI584GKdEeUx5U/gmcVQIvbtUJ0eGeVY02oUy7gINA==
X-Received: by 2002:a0c:e5c9:: with SMTP id u9mr3867908qvm.53.1540411120042;
        Wed, 24 Oct 2018 12:58:40 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.38
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:39 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 00/13] client-side support for "inter" SSC copy
Date:   Wed, 24 Oct 2018 15:58:23 -0400
Message-Id: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
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

v2:
-- VFS changes are to remove VFS check for same copy_file_range
functions before calling it. Instead add the appropriate checks
to the existing implementors of the copy_file_range.
-- Changed the check for the "intra" vs "inter" based on the
serverowner instead of the IPs and merged it with the 1st caller
patch
-- Addressed Anna's comments to ifdef the nfs42_copy_notify in
nfs42.h to make for proper compiling
-- Removed a leftover dprintk from the nfs42_ssc_open

Olga Kornievskaia (13):
  VFS permit cross device vfs_copy_file_range
  CIFS: add cross-device check for copy_file_range
  OverlayFS: add cross-device check for copy_file_range
  NFS: add cross file system check for copy_file_range
  VFS: Don't copy beyond the end of the file
  NFS NFSD defining nl4_servers structure needed by both
  NFS add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY
  NFS also send OFFLOAD_CANCEL to source server
  NFS inter ssc open
  NFS skip recovery of copy open on dest server
  NFS for "inter" copy treat ESTALE as ENOTSUPP
  NFS COPY handle ERR_OFFLOAD_DENIED

 Documentation/filesystems/porting |   7 ++
 Documentation/filesystems/vfs.txt |   6 +-
 fs/cifs/cifsfs.c                  |   2 +
 fs/nfs/nfs42.h                    |  15 ++-
 fs/nfs/nfs42proc.c                | 129 ++++++++++++++++++++++---
 fs/nfs/nfs42xdr.c                 | 193 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h                  |  10 ++
 fs/nfs/nfs4client.c               |   2 +-
 fs/nfs/nfs4file.c                 | 122 +++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                 |   6 +-
 fs/nfs/nfs4state.c                |  14 +++
 fs/nfs/nfs4xdr.c                  |   1 +
 fs/overlayfs/file.c               |   3 +
 fs/read_write.c                   |  12 +--
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 17 files changed, 539 insertions(+), 26 deletions(-)

-- 
1.8.3.1

