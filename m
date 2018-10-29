Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E0AC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE2922082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kWCsbi2z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE2922082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728152AbeJ3Dx7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:53:59 -0400
Received: from mail-qk1-f170.google.com ([209.85.222.170]:41827 "EHLO
        mail-qk1-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726384AbeJ3Dx7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:53:59 -0400
Received: by mail-qk1-f170.google.com with SMTP id 189so4239606qkj.8;
        Mon, 29 Oct 2018 12:04:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=AB21n7Fz1+mQpP9q6hMxmdy82ZRdinWfwZ9A9CstRQk=;
        b=kWCsbi2zVVKWlpctInnPCg2UJMjFlfMChexnflTKTev+t+U3PQ3DzRgrgkpmCwoCQC
         GBbTKUyb9hOb/oOBHdRqTvV9NKXnek5CNntZb+hN7O6SS2lTfNkneo8xHD5lZoSjLGfD
         40cjFsXrLK0N2RW1tfe8cStlDWC479DkRNxIXpIEIt5ivEaSPfwm7RfZEZPt63pIvG5s
         uDSNRSZ7xnMONWQOackRKKXVjtn6BSvTAAEygsNmSlIsyQxMZf9W/zfioE06ePvuiy1I
         qHZFdmae7xYHcdkDbpSmhnIG2CR/dh2bhNKkg6+XNOeScA00EySzH3gH9H2/8W6OVfrQ
         QzJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=AB21n7Fz1+mQpP9q6hMxmdy82ZRdinWfwZ9A9CstRQk=;
        b=AH0ywi8nyakMCDLtm6cJTwi0D9KyNKVYVfbq5BIssTGkuWhHaBKSyuMbqBuyCIB4nI
         3Tr22LT/wEyBHFZB7KRrobzkOxhQq/RDrlYLkXm42L7qFGgnroMtki6jpYFctHJiFrww
         mU9Qzw26xQd9firg/DCQI5DQgXFeygVZhplLZoB3C8JyfFCRPSA0wi9TCdoA+KEQ/WoF
         m9DLZV2rav1A3r5uPaYHCm+JstINxDIz83ml2bDRG3Ot/Np2MHb9yvrt1pGGS3dQXLLl
         WqOmBtkEIX8hwlakRvRK28Q72zWe2HI+HSwClT6GFytioCeplnHhQ07wY7iE6OOWtCkv
         YVag==
X-Gm-Message-State: AGRZ1gJsxdU9P0ZQn7yLS0DmA4rfv2hC1IXVWETKQZ3CqzA1Sq8DWv/n
        oYJG55GGjNl8ciBVKUeVXRs=
X-Google-Smtp-Source: AJdET5eKXasU+zJN5oz/xbqPNT26NeLwn/T/ZNj69wVyB4pUHrjzGyhEivK5t8zCvcNODr0X1aJIsA==
X-Received: by 2002:a37:188:: with SMTP id u8mr8004688qkg.263.1540839840213;
        Mon, 29 Oct 2018 12:04:00 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.03.57
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:03:58 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 00/12] client-side support for "inter" SSC copy
Date:   Mon, 29 Oct 2018 15:03:44 -0400
Message-Id: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
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

v6:
-- in the VFS patches: made suggested changes to first allow cross 
device copy for all filesystem via do_splice, still checking 
superblocks for clone/copy_file_range. in the 2nd patch allow
individual copy_file_range to deal with cross device support.
-- fixes NFS cross file system check as per Matthew comments.

Olga Kornievskaia (12):
  VFS: generic cross-device copy_file_range() support for all
    filesystems
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
 fs/read_write.c                   |   9 +-
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 16 files changed, 535 insertions(+), 25 deletions(-)

-- 
1.8.3.1

