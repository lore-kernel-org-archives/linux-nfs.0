Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbcBCOBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2016 09:01:15 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <56AFEA5E.2080401@redhat.com>
References: <56AFEA5E.2080401@redhat.com> <20160125164111.9466.79976.stgit@warthog.procyon.org.uk> <20160125164937.9670.4281.stgit@warthog.procyon.org.uk>
To: John Snow <jsnow@redhat.com>
Cc: dhowells@redhat.com, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org,
        neilb@suse.de, linux-fsdevel@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [Linux-cachefs] [PATCH 2/2] Suspend/resume culling based on recently released file/block counts
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 Feb 2016 14:01:12 +0000
Message-ID: <20004.1454508072@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

John Snow <jsnow@redhat.com> wrote:

> > +			if (!*sp || !isspace(*sp) || b_thresh == 0)
> > +				cfgerror("Invalid resume threshold (blocks)");
> 
> Seems to me like we're mixing parsing errors with invalid configuration
> error messages, but I'm just bike-shedding aboard the SS Howells.

How about this further modification?

-			if (!*sp || !isspace(*sp) || b_thresh == 0)
+			if (!*sp || !isspace(*sp))
+				cfgerror("Error parsing resume threshold (blocks)");
+			if (b_thresh == 0)
 				cfgerror("Invalid resume threshold (blocks)");
 			for (; isspace(*sp); sp++) {;}
 
@@ -470,7 +472,9 @@ int main(int argc, char *argv[])
 				f_thresh = ULLONG_MAX;
 			} else {
 				f_thresh = strtoul(sp, &sp, 10);
-				if (*sp || f_thresh == 0)
+				if (*sp)
+					cfgerror("Error parsing resume threshold (files)");
+				if (f_thresh == 0)
 					cfgerror("Invalid resume threshold (files)");

David
