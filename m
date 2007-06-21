From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation limit based on RAM size
Date: Thu, 21 Jun 2007 12:15:31 -0400
Message-ID: <20070621161531.GC4094@fieldses.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756549AbXFUQQG@vger.kernel.org>
In-Reply-To: <1070621043112.1144@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

I missed a compile warning here, apologies.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c79f742..fbbbcab 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3204,7 +3204,7 @@ get_nfs4_grace_period(void)
 }
 
 static void
-set_max_delegations()
+set_max_delegations(void)
 {
 	struct sysinfo sys;
