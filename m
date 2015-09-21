Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:62996 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbbIUUun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 16:50:43 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/4] GSSD: Do not fork when UID = 0
Date: Mon, 21 Sep 2015 16:50:05 -0400
Message-ID: <1442868609-1812-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Jeff Layton worked on this patch set with me.

patch 0001 and 0002 clean up process_krb5_upcall() by moving the two cases into
helper functions.

patch 0003 is the heart of this patch set.

commit f9cac65972da588d5218236de60a7be11247a8aa added the fork to
process_krb5_upcall so that the child assumes the uid of the principal
requesting service. This is good for the reasons listed in the commit.

When machine credentials are used, a gssd_k5_kt_princ entry is added to
a global list and used by future upcalls to note when valid machine credentials
have been obtained. When a child process performs this task, the entry to the
global list is lost upon exit, and all upcalls for machine credentials re-fetch
a TGT, even when a valid TGT is in the machine kerberos credential cache.

Since forking is not necessary when the principal has uid=0, solve the
gssd_k5_kt_princ_list issue by only forking when the uid != 0.

Please do more testing. Comments welcome.

Andy Adamson (4):
  GSSD: move process_krb5_upcall machine cred case to helper function
  GSSD: move process_krb5_updcall non machine cred case to helper
    function
  GSSD only fork when uid is not zeo
  GSSD: clean up machine credentials

 utils/gssd/gssd.c      |  10 +-
 utils/gssd/gssd_proc.c | 244 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 154 insertions(+), 100 deletions(-)

-- 
1.8.3.1

