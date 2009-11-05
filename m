From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] NFS: Display compressed (shorthand) IPv6 in /proc/mounts
Date: Thu, 05 Nov 2009 13:22:42 -0500
Message-ID: <20091105182242.2796.19524.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37599
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757678AbZKESWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:22:50 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent changes to snprintf() introduced the %pI6c formatter, which can
display an IPv6 address with standard shorthanding.  Use this new
formatter when displaying IPv6 server addresses in /proc/mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 90be551..968c7ac 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -505,7 +505,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	}
 	case AF_INET6: {
 		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-		seq_printf(m, ",mountaddr=%pI6", &sin6->sin6_addr);
+		seq_printf(m, ",mountaddr=%pI6c", &sin6->sin6_addr);
 		break;
 	}
 	default:

