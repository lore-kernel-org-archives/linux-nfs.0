From: Greg KH <gregkh@suse.de>
Subject: [patch 03/16] sunrpc: fix possible overrun on read of
	/proc/sys/sunrpc/transports
Date: Wed, 3 Sep 2008 10:32:47 -0700
Message-ID: <20080903173247.GD10429@suse.de>
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
	Greg Banks <gnb@sgi.com>, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Tom Tucker <tom@opengridcomputing.com>,
	Ingo Oeser <ioe-lkml-MFZNYGWX9eyELgA04lAiVw@public.gmane.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58364 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbYICRtb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2008 13:49:31 -0400
In-Reply-To: <20080903173218.GA10429@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


2.6.25-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Cyrill Gorcunov <gorcunov@gmail.com>

commit 27df6f25ff218072e0e879a96beeb398a79cdbc8 upstream

Vegard Nossum reported
----------------------
> I noticed that something weird is going on with /proc/sys/sunrpc/transports.
> This file is generated in net/sunrpc/sysctl.c, function proc_do_xprt(). When
> I "cat" this file, I get the expected output:
>    $ cat /proc/sys/sunrpc/transports
>    tcp 1048576
>    udp 32768

> But I think that it does not check the length of the buffer supplied by
> userspace to read(). With my original program, I found that the stack was
> being overwritten by the characters above, even when the length given to
> read() was just 1.

David Wagner added (among other things) that copy_to_user could be
probably used here.

Ingo Oeser suggested to use simple_read_from_buffer() here.

The conclusion is that proc_do_xprt doesn't check for userside buffer
size indeed so fix this by using Ingo's suggestion.

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
CC: Ingo Oeser <ioe-lkml-MFZNYGWX9eyELgA04lAiVw@public.gmane.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Greg Banks <gnb@sgi.com>
Cc: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/sunrpc/sysctl.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -60,24 +60,14 @@ static int proc_do_xprt(ctl_table *table
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char tmpbuf[256];
-	int len;
+	size_t len;
+
 	if ((*ppos && !write) || !*lenp) {
 		*lenp = 0;
 		return 0;
 	}
-	if (write)
-		return -EINVAL;
-	else {
-		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
-		if (!access_ok(VERIFY_WRITE, buffer, len))
-			return -EFAULT;
-
-		if (__copy_to_user(buffer, tmpbuf, len))
-			return -EFAULT;
-	}
-	*lenp -= len;
-	*ppos += len;
-	return 0;
+	len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
+	return simple_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
 }
 
 static int

-- 
