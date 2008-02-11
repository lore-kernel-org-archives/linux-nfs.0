From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] NLM: LOCKD fails to load if CONFIG_SYSCTL is not set
Date: Mon, 11 Feb 2008 17:12:09 -0500
Message-ID: <20080211221209.1047.39544.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:1784 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756958AbYBKWMi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2008 17:12:38 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce Fields says:
"By the way, we've got another config-related nit here:

	http://bugzilla.linux-nfs.org/show_bug.cgi?id=156

You can build lockd without CONFIG_SYSCTL set, but then the module will
fail to load."

It looks like sysctl is needed for passing nsm_local_state between the
user space and the kernel.  If that's not available, NSM notification
from user space appears not to work.

It's not a fatal error if the nsm_local_state file doesn't exist, however
I've chosen to ensure CONFIG_SYSCTL is selected if LOCKD is selected.  The
other choice is for nlm_init() to ignore the return code from the sysctl
root registration call, but I think administrators would be surprised
that NSM isn't working in this case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 6c4e17b..0c8f85d 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1737,6 +1737,7 @@ config NFSD_V4
 
 config LOCKD
 	tristate
+	select SYSCTL
 
 config LOCKD_V4
 	bool

