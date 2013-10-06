Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f170.google.com ([209.85.215.170]:63275 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab3JFHlD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 03:41:03 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so2580371eak.29
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 00:41:02 -0700 (PDT)
Message-ID: <5251140B.4000203@primarydata.com>
Date: Sun, 06 Oct 2013 10:40:59 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] pnfsd: refactor nfs4_process_layout_stateid
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_process_layout_stateid is used by layout get, commit, and return.
The layout get case is different in that it allows the client to initiate
the layout stateid using an open/lock/delegation stateid.
Where in the layout commit and return cases an error must be returned
if the client uses a non-layout stateid.

0001-SQUASHME-fix-lo_destroy_list-nested-definition.patch
0002-SQUASHME-pnfsd-nfs4_find_create_layout_stateid.patch
0003-SQUASHME-pnfsd-no-need-for-find_file-in-layout-commi.patch
0004-SQUASHME-pnfsd-fixup-error-code-for-layout_commit.patch

Benny
