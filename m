Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:42185 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910AbbIWOaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 10:30:52 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/4] GSSD: Do not fork when UID = 0
Date: Wed, 23 Sep 2015 10:30:12 -0400
Message-ID: <1443018616-1335-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 2:
responded to comments.
- removed some printerr from 0003
- removed the SIGKILL call from 0004

Version 1:
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

-->Andy

Andy Adamson (4):
  GSSD: move process_krb5_upcall machine cred case to helper function
  GSSD: move process_krb5_updcall non machine cred case to helper
    function
  GSSD only fork when uid is not zeo
  GSSD: clean up machine credentials

 utils/gssd/gssd.c      |  11 ++-
 utils/gssd/gssd_proc.c | 239 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 150 insertions(+), 100 deletions(-)

-- 
1.9.3 (Apple Git-50)

