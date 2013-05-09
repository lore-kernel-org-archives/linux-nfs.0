Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f181.google.com ([209.85.215.181]:61813 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3EIIvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 04:51:07 -0400
Received: by mail-ea0-f181.google.com with SMTP id a15so1397406eae.12
        for <linux-nfs@vger.kernel.org>; Thu, 09 May 2013 01:51:05 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-80-49-130.static.bezeqint.net. [82.80.49.130])
        by mx.google.com with ESMTPSA id t9sm2716764eeo.11.2013.05.09.01.51.04
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 May 2013 01:51:04 -0700 (PDT)
Message-ID: <518B6377.3000207@tonian.com>
Date: Thu, 09 May 2013 11:51:03 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/38] pnfsd: Use layout state to track layouts and misc.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset includes:
- API usage changes that originated in v3.8 around the use of nfsd_net
  to search clientid and stateid.
  - temporary removal of notify_deviceid and get_state pnfs callback API
    until we implement a mechanism to look up global stateids and clientids
    provided by the file system.
- rewriting of the layout tracking mechanism, using
  the layout_state structure to keep a list of all derived layout
  and enlisting the layout_state on its respective file and client rather
  than the layout structure themselves.
- various bug fixes

API related reverts:
[PATCH 01/38] Revert "SQUASHME: pnfsd: Fix compiler warning when
[PATCH 02/38] Revert "pnfsd: Clean up all stateids on DS on
[PATCH 03/38] Revert "pnfsd: update ds stateid from mds"
[PATCH 04/38] pnfsd-lexp: remove get_state
[PATCH 05/38] Revert "FIXME pnfsd: gfs2 temp turn off DS stateid
[PATCH 06/38] Revert "pnfsd: nfs4_preprocess_pnfs_ds_stateid"
[PATCH 07/38] Revert "pnfsd: Add way of determining if a client has
[PATCH 08/38] Revert "pnfsd: Notify device ID changes"
[PATCH 09/38] Revert "pnfsd: filelayout: file layout specific
[PATCH 10/38] Revert "pnfsd: Use ds_state_lock to protect retrieving
[PATCH 11/38] Revert "pnfsd: ds state"
[PATCH 12/38] Revert "pnfsd: decode getdeviceinfo notify types."
[PATCH 13/38] Revert "pnfsd: set_device_notify"
[PATCH 14/38] FIXME: temporarily disable create_layout_recall_list

API related changes:
[PATCH 15/38] SQUASHME: pnfsd: use nfsd_net for layoutget starting
[PATCH 16/38] SQUASHME: pnfsd: use nfsd4_init_callback starting v3.8
[PATCH 17/38] SQUASHME: use nfsd_net for layoutreturn starting v3.8

bug fixes:
[PATCH 18/38] SQUASHME: pnfsd: fix destroy_layout_state
[PATCH 19/38] SQUASHME: pnfsd: get rid of depdency on nfsd_serv
[PATCH 20/38] SQUASHME: pnfsd: merge_layout needs to acquire the
[PATCH 21/38] SQUASHME: pnfsd: return bool from merge_layout and fix
[PATCH 22/38] SQUASHME: pnfsd: hanging nfs4_layoutrecall on the
[PATCH 23/38] DEBUG: pnfsd: ASSERT_LAYOUT_LOCKED
[PATCH 24/38] pnfsd: cause oops when stop the nfs server

layout tracking:
[PATCH 25/38] pnfsd: layout state: rename fi_layout_states member
[PATCH 26/38] pnfsd: layout state: move initialization of ls_roc
[PATCH 27/38] pnfsd: layout state: introduce ls_file backpointer
[PATCH 28/38] pnfsd: layout state: introduce ls_client backpointer
[PATCH 29/38] pnfsd: layout state: hang layouts on layout state
[PATCH 30/38] pnfsd-lexp: fixup recall_layout
[PATCH 31/38] pnfsd: use the layout stateid for layout recalls
[PATCH 32/38] pnfsd: cosmetic fixes
[PATCH 33/38] pnfsd: pass layout stateid down to fs on layoutget
[PATCH 34/38] pnfsd: pass layout stateid down to fs on layoutreturn
[PATCH 35/38] pnfsd: use layout stateid for is_layout_recalled
[PATCH 36/38] pnfsd: deprecate cbl_seg.clientid
[PATCH 37/38] pnfsd: don't use clientid in merge_layout
[PATCH 38/38] pnfsd: remove clientid member from struct
