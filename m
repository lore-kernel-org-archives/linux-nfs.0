From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: non working tests on unsigned f->pseudoflavor
Date: Tue, 21 Apr 2009 18:34:29 -0400
Message-ID: <20090421223429.GF27411@fieldses.org>
References: <49EDD367.9000709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38623 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbZDUWec (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 18:34:32 -0400
In-Reply-To: <49EDD367.9000709@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied.

On Tue, Apr 21, 2009 at 04:08:39PM +0200, Roel Kluin wrote:
> vi include/linux/nfsd/export.h +77
> and note that struct exp_flavor_info f->pseudoflavor in secinfo_parse() is
> unsigned. Should there maybe be a test:
> 
> if (f->pseudoflavor > MAX)
> 
> (and what should MAX be then?)

I think the only sensible thing would actually be to attempt to verify
that we support each pseudoflavor, but that's a little more work; for
now I just modified your patch to leave a note that we should do that
some day.

Another todo if anyone's interested would be to modify the code that
looks for supported pseudoflavors to attempt to load the right module if
necessary--I saw the lack of this cause a problem somewhere recently.

--b.

Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Tue Apr 21 16:08:39 2009 +0200

    rpcgss: remove redundant test on unsigned.
    
    Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5839b22..6eb9181 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -464,16 +464,11 @@ static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
 		if (err)
 			return err;
 		/*
-		 * Just a quick sanity check; we could also try to check
-		 * whether this pseudoflavor is supported, but at worst
-		 * an unsupported pseudoflavor on the export would just
-		 * be a pseudoflavor that won't match the flavor of any
-		 * authenticated request.  The administrator will
-		 * probably discover the problem when someone fails to
-		 * authenticate.
+		 * XXX: It would be nice to also check whether this
+		 * pseudoflavor is supported, so we can discover the
+		 * problem at export time instead of when a client fails
+		 * to authenticate.
 		 */
-		if (f->pseudoflavor < 0)
-			return -EINVAL;
 		err = get_int(mesg, &f->flags);
 		if (err)
 			return err;
