Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8FC6C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7CA8A2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O49dT29G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CA8A2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725993AbeLAHOP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:15 -0500
Received: from mail-ot1-f68.google.com ([209.85.210.68]:45667 "EHLO
        mail-ot1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:15 -0500
Received: by mail-ot1-f68.google.com with SMTP id 32so6202379ota.12;
        Fri, 30 Nov 2018 12:03:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=p66SgXd/IWkiCHGat74HU3eg7V/dOlY9pk7CzcQULKU=;
        b=O49dT29GCk4k4VyyUV856khzeajoTZ/yIYxIsPGl2jn0mnLkQHd/2YUNmY+tUt5QPY
         taQd3jsFZTj165WyLkyJ2s5OZRCOAIVGDnKCxdlFzU+l+rzUgRtxT3xV5I8IxdXqmwU5
         7/oizqfkrpByy/V3nYzVxDM8ibXteygTTAs0NQrZpff4tb8UXKhOTnZWs3nRR6iWfXvh
         ZgbLSBL8cyx1oB0ubh7JN/4HoyzSb07Cuhm18kXzRqGr53AXgo01smfss+EKksC5uj4X
         Y2P41xNAaX4pK2hJb4Rbu/7bFQAdfQyRpDj83RqhICtqqMlWaOpLf7YkXEgt5XeSRAEx
         ihqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=p66SgXd/IWkiCHGat74HU3eg7V/dOlY9pk7CzcQULKU=;
        b=rL4M0ubWe2/CVWIpjeEKrWvSvnA2gF3op2VgbsV0tH2hA0Ugssrluti0jLHTaYmnwi
         XWvQJMXXVERWQ71GMNOtYPvIj6UAs8twvaCkGsln0udq4klcUMEAEt6aam75/GBgGNoa
         A3kafH4ChKk3sqHZu3RjaSEBuhaQ4SAbKYTjJVdC3nDoXYR2HuR/mlMsXHUMnSg13pMs
         6Z9tUav0JqIQ86Rut0Jb3r38TxxEeVTBTAYEB6cGAP1pjGdBthk/0qUt4JeJEncIbUVA
         Ql+MrgcjIjNjBg5bRqnUspAMiAVn/Bg5PqcE0l4+/RvyH+XlASCUuALKW2nQzZHWFCO9
         JbAA==
X-Gm-Message-State: AA+aEWZcZp34AI+mmgq9gYYk8Bh5WZG5WwSPawec/NYU1wH4E1ElYxL0
        TD3OONsjlYSNoQ5gPeauI9c=
X-Google-Smtp-Source: AFSGD/WBbQk6TxbiyotNrHucZbKfLYmTUrDvuEMyBO2Xv6PqjkZv4MF/7m/uNzm95R4kOeJf2Of2ZA==
X-Received: by 2002:a05:6830:1283:: with SMTP id z3mr4132227otp.92.1543608230432;
        Fri, 30 Nov 2018 12:03:50 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.49
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:03:49 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 00/10] server-side support for "inter" SSC copy
Date:   Fri, 30 Nov 2018 15:03:38 -0500
Message-Id: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch series adds support for NFSv4.2 copy offload feature
allowing copy between two different NFS servers.

This functionality depends on the VFS ability to support generic
copy_file_range() where a copy is done between an NFS file and
a local file system.

This feature is enabled by the kernel module parameter --
inter_copy_offload_enable -- and by default is disabled. There is
also a kernel compile configuration of NFSD_V4_2_INTER_SSC that
adds dependency on the NFS client side functions called from the
server.

These patches work on top of existing async intra copy offload
patches. For the "inter" SSC, the implementation only supports
asynchronous inter copy.

On the source server, upon receiving a COPY_NOTIFY, it generate a
unique stateid that's kept in the global list. Upon receiving a READ
with a stateid, the code checks the normal list of open stateid and
now additionally, it'll check the copy state list as well before
deciding to either fail with BAD_STATEID or find one that matches.
The stored stateid is only valid to be used for the first time
with a choosen lease period (90s currently). When the source server
received an OFFLOAD_CANCEL, it will remove the stateid from the
global list. Otherwise, the copy stateid is removed upon the removal
of its "parent" stateid (open/lock/delegation stateid).

On the destination server, upon receiving a COPY request, the server
establishes the necessary clientid/session with the source server.
It calls into the NFS client code to establish the necessary
open stateid, filehandle, file description (without doing an NFS open).
Then the server calls into the copy_file_range() to preform the copy
where the source file will issue NFS READs and then do local file
system writes (this depends on the VFS ability to do cross device
copy_file_range().

v2:
-- in on top of 4.20-rc4 + client side inter patch series
-- VFS changes to do enable generic copy_file_range() and then NFS
falls back on generic_copy_file_range() for previous EXDEV/OPNOTSUPP
errors
-- hopefully addressed Bruce's review comments (highlights are):
   --- copy_notify patch: addressed naming, sc_cp_list access is
now protected by s2s_cp_lock
   --- fillin netloc4 patch: address the size and added WARN_ON
   --- add ca_source to COPY: decode only 1 address, dont allocate
memory (the rest into dummy)
   --- check stateid against stored: moved the refcount under lock
   --- allow stale filehandle: adding a loop to go thru the ops in
the compound, store/manage puttfh if copy is present in the compound
mark the source putfh as "no verify".

All the patches (client inter) and this patch series is available
from git://linux-nfs.org/projects/aglo/linux.git under the "linux-ssc"
branch

Olga Kornievskaia (10):
  VFS generic copy_file_range() support
  NFS fallback to generic_copy_file_range
  NFSD fill-in netloc4 structure
  NFSD add ca_source_server<> to COPY
  NFSD return nfs4_stid in nfs4_preprocess_stateid_op
  NFSD add COPY_NOTIFY operation
  NFSD check stateids against copy stateids
  NFSD generalize nfsd4_compound_state flag names
  NFSD: allow inter server COPY to have a STALE source server fh
  NFSD add nfs4 inter ssc to nfsd4_copy

 fs/nfs/nfs4file.c    |   9 +-
 fs/nfsd/Kconfig      |  10 ++
 fs/nfsd/nfs4proc.c   | 406 ++++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c  | 124 ++++++++++++++--
 fs/nfsd/nfs4xdr.c    | 166 ++++++++++++++++++++-
 fs/nfsd/nfsd.h       |  32 ++++
 fs/nfsd/nfsfh.h      |   5 +-
 fs/nfsd/nfssvc.c     |   6 +
 fs/nfsd/state.h      |  21 ++-
 fs/nfsd/xdr4.h       |  37 ++++-
 fs/read_write.c      |  66 +++++++--
 include/linux/fs.h   |   7 +
 include/linux/nfs4.h |   1 +
 mm/filemap.c         |   6 +-
 14 files changed, 810 insertions(+), 86 deletions(-)

-- 
1.8.3.1

