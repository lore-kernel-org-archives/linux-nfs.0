Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f180.google.com ([209.85.210.180]:60769 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3EMQZM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 12:25:12 -0400
Received: by mail-ia0-f180.google.com with SMTP id l27so1997853iae.11
        for <linux-nfs@vger.kernel.org>; Mon, 13 May 2013 09:25:12 -0700 (PDT)
Received: from seurat.1015granger.net (adsl-99-26-161-222.dsl.sfldmi.sbcglobal.net. [99.26.161.222])
        by mx.google.com with ESMTPSA id wn10sm18077750igb.2.2013.05.13.09.25.10
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 May 2013 09:25:11 -0700 (PDT)
Subject: [PATCH 0/2] [RFC] Maybe avoid gssd upcall timeout
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 13 May 2013 12:25:09 -0400
Message-ID: <20130513161515.1942.845.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here's a stab at addressing the 15 second wait for some 3.10 sec=sys
mounts where the client is not running rpc.gssd.

After reverting the "use krb5i for SETCLIENTID" patch, I've added
the AUTH_SYS fallback in the EACCES case in
nfs4_discover_server_trunking().  I'm not sure whether we need to
supplement what's there now, or replace it.

"case -ENOKEY:" is added so the kernel will recognize that when gssd
is changed to return that instead of EACCES in this case.  If the
second patch is appled to 3.7 stable and following, it might be a way
to address the same regression in older kernels.

I've been focused on another bug this week, so this has seen very
light testing only.  Looking for comments.

---

Chuck Lever (2):
      NFS: Revert commit 4edaa308 and follow-on fixes
      NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)


 fs/nfs/nfs4client.c |    4 +--
 fs/nfs/nfs4state.c  |   65 +++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 61 insertions(+), 8 deletions(-)

-- 
Chuck Lever
