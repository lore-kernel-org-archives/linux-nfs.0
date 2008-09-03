From: Greg KH <gregkh@suse.de>
Subject: [patch 05/16] nfsd: fix buffer overrun decoding NFSv4 acl
Date: Wed, 3 Sep 2008 10:32:52 -0700
Message-ID: <20080903173252.GF10429@suse.de>
References: <20080903172849.927077124@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes-a5Mqy2EUIFVAfugRpC6u6w@public.gmane.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw-lrwSPXAIdEw7YuNMryXyOw@public.gmane.org>,
	Chris Wedgwood <reviews-vFB7bnJMxjixIvdkapsUdQ@public.gmane.org>,
	Michael Krufky <mkrufky-dJidKbW2IEtAfugRpC6u6w@public.gmane.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco-OG872enO0lhw4vQD1pnt9QC/G2K4zDHf@public.gmane.org>,
	Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	David Richter <richterd@citi.umich.edu>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58514 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758912AbYICRuU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2008 13:50:20 -0400
In-Reply-To: <20080903173218.GA10429@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2.6.25-stable review patch.  If anyone has any objections, please let us know.

------------------
From: J. Bruce Fields <bfields@citi.umich.edu>

commit 91b80969ba466ba4b915a4a1d03add8c297add3f upstream

The array we kmalloc() here is not large enough.

Thanks to Johann Dahm and David Richter for bug report and testing.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: David Richter <richterd@citi.umich.edu>
Tested-by: Johann Dahm <jdahm@umich.edu>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/nfsd/nfs4acl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -443,7 +443,7 @@ init_state(struct posix_acl_state *state
 	 * enough space for either:
 	 */
 	alloc = sizeof(struct posix_ace_state_array)
-		+ cnt*sizeof(struct posix_ace_state);
+		+ cnt*sizeof(struct posix_user_ace_state);
 	state->users = kzalloc(alloc, GFP_KERNEL);
 	if (!state->users)
 		return -ENOMEM;

-- 
