Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A61C7ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C95920834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FMTrNgVi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C95920834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727576AbeJZG0P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:15 -0400
Received: from mail-qt1-f178.google.com ([209.85.160.178]:36874 "EHLO
        mail-qt1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726149AbeJZG0P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:15 -0400
Received: by mail-qt1-f178.google.com with SMTP id d14-v6so11810999qto.4;
        Thu, 25 Oct 2018 14:51:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=R13wry7/ZCTyophXBDtsTyFJr/QPjy8SJUCEvCO3YLM=;
        b=FMTrNgViZ6EhuifFTfh/3UysBf0F5WADlku5/EXYoP78hVdBPYuKNniYuZEin0PXqz
         CIdcK8HDfbbym0rpdSCnKpIU5RDkW8sb3TyZgegHxDpRasvc0xK2C4qndF1Sz+5wEqKA
         wddnyrRGZ/+B4jt4luqjBApdz/P6AvvrvM3PHXSbUsfUkQGTkDqMmLtxCKhxKVd/TWyC
         mpeLiPWkD+V+IUCqrsB1gzS9tTXPEnphxz0ANU1uObULzyWTHVsBU00vqRqEQCL+ZLN8
         kInsXKGqTO7/vlcOWBqWNmAmK5f0WEQTOmVDsGiZ9KdgM8u8w5PT7/18NCTymxyxE2WZ
         MwfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=R13wry7/ZCTyophXBDtsTyFJr/QPjy8SJUCEvCO3YLM=;
        b=gz8tD9m7nv+ZzTlgSEGAtcYW3MGjFNVc63kilbk9DEja9b2mZs+l0eMMbd9GQKlk5a
         JyNYpwgAg3IHHA59PqAeQdpbskLzwiQ39Rwaw9zJ4MKsS4eMQh+cKWSiJY32IL1RNYKH
         hmjXCyLC+TRljxYpkKprAXqwXFeXVqex82k/uWwfZOeyO4kha9TtAntgMoSblFTqwKyR
         60l0Ze1yKsEUq+i3BiCclBLjM6H/bTXKXtdxj2lKBB1A/CREV1wCriV6PAsQQBwZFbHY
         c3vmYAWW8QA95EPiTNToAasHgecUbVg6cLCNQyktXomYE2YPgfVk2W5PEBcP0j632iO7
         8+zw==
X-Gm-Message-State: AGRZ1gLMtuSHE0GhlDpwrGOOIq2PjefbNo86a+kQd5tk4KmdY1vp8fY7
        zBZsjyOygxsYreyX+3WZMgU=
X-Google-Smtp-Source: AJdET5di7CEaIu9KJOmuXbW941C1UdAVXHvIFBd8K05VrsMjE+RboE7c9sIqhD3amlmmjYXnagpp+A==
X-Received: by 2002:a0c:9c8c:: with SMTP id i12mr969693qvf.122.1540504310340;
        Thu, 25 Oct 2018 14:51:50 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.48
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:49 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 00/11] client-side support for "inter" SSC copy
Date:   Thu, 25 Oct 2018 17:51:35 -0400
Message-Id: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
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

v3:
-- Combine CIFS,OverlayFS,NFS checks with the VFS patch that relaxed
the cross device check.
-- Reordered the patches to first enforce cross sb check in NFS,
relax it in VFS, then add support to the NFS, then add a patch to
NFS to check for the cross fs type instead.
-- fixed kbuild suggestion to change PTR_ERR to PTR_ERR_OR_ZERO

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
  NFS replace cross device with cross filesystem check in
    copy_file_range

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

