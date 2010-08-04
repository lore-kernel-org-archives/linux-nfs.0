Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57129 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756761Ab0HDJQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 05:16:02 -0400
Message-ID: <4C592F85.8070308@cn.fujitsu.com>
Date: Wed, 04 Aug 2010 17:14:45 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix bug that client use a invaild delegation
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all

  I find a bug at RHEL6Beta2. If client return nfsi->delegation, some open_stateid
 still have the NFS_DELEGATED_STATE bit, and another open process which has some
 owner will not clear this bit, it will not use the new open stateid to fill 
 state->stateid, just fill state->open_stateid. 
 Then other IO operation will use the old delegation, it will get NFS4ERR_BAD_STATEID.
 
  Thought my test program just FAIL at RHEL6Beta2, latest kernel is OK,
 but i thinks the latest kernel maybe have the some bug.

---

Bian Naimeng (2):
	[PATCH 1/2] Make lock inode before lock nfs4_state_owner
	[PATCH 2/2] We should clear NFS_DELEGATED_STATE after return delegation

 fs/nfs/nfs4proc.c  |   15 ++++++++++++++-
 fs/nfs/nfs4state.c |   16 +++++++++-------
 2 files changed, 23 insertions(+), 8 deletions(-)

-- 
Regards
Bian Naimeng

