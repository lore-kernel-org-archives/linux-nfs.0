Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AD9AC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6416F21871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727066AbeLROaT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from mx1.redhat.com ([209.132.183.28]:55876 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726426AbeLROaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 11231C0669D2;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D12EC4D722;
        Tue, 18 Dec 2018 14:30:18 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 803B9207AD; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 0/7] restore nfsdcld
Date:   Tue, 18 Dec 2018 09:30:11 -0500
Message-Id: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When nfsdcld was released, it was quickly deprecated in favor of the
nfsdcltrack usermodehelper, so as to not require another running daemon.
The nfsdcld code was removed from nfs-utils in 2012.  That prevents
NFSv4 clients from reclaiming locks from nfsd's running in containers,
since neither nfsdcltrack nor the legacy client tracking code work in
containers.  These patches restore the nfsdcld code.

These patches are intended to go alongside some kernel patches that
introduce an enhancement that allows nfsd to "slurp" up the client
records during client tracking initialization and store them internally
in hash table.  This enables nfsd to check whether an NFSv4 client is
allowed to reclaim without having to do an upcall to nfsdcld.  It also
allows nfsd to decide to end the v4 grace period early if the number of
RECLAIM_COMPLETE operations it has received from "known" clients is
equal to the number of entries in the hash table.  It also allows nfsd
to skip the v4 grace period altogether if it knows there are no clients
allowed to reclaim.

The new nfsdcld code will work with older kernels, however in that case
there is no ability for nfsd to exit the grace period early or skip the
grace period altogether.

v2:
- Use sqlite3_column_int64() instead of sqlite3_column_int() to query
  the current & recovery values from the grace table
- Uncommented the nfsdcld section header in nfs.conf

Scott Mayhew (7):
  Revert "nfsdcltrack: remove the nfsdcld daemon"
  nfsdcld: move nfsdcld to its own directory
  nfsdcld: a few enhancements
  nfsdcld: remove some unused functions
  nfsdcld: the -p option should specify the rpc_pipefs mountpoint
  nfsdcld: add /etc/nfs.conf support
  systemd: add a unit file for nfsdcld

 .gitignore                   |   1 +
 configure.ac                 |  23 +
 nfs.conf                     |   4 +
 support/include/cld.h        |   1 +
 systemd/nfs-server.service   |   2 +
 systemd/nfsdcld.service      |  11 +
 utils/Makefile.am            |   4 +
 utils/nfsdcld/Makefile.am    |  19 +
 utils/nfsdcld/cld-internal.h |  30 ++
 utils/nfsdcld/nfsdcld.c      | 761 +++++++++++++++++++++++++++++++
 utils/nfsdcld/nfsdcld.man    | 199 +++++++++
 utils/nfsdcld/sqlite.c       | 837 +++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h       |  33 ++
 13 files changed, 1925 insertions(+)
 create mode 100644 systemd/nfsdcld.service
 create mode 100644 utils/nfsdcld/Makefile.am
 create mode 100644 utils/nfsdcld/cld-internal.h
 create mode 100644 utils/nfsdcld/nfsdcld.c
 create mode 100644 utils/nfsdcld/nfsdcld.man
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

-- 
2.17.1

