Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59888 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713Ab0JKEQ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 00:16:26 -0400
Date: Mon, 11 Oct 2010 15:16:15 +1100
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/15] Fixes for nfs-utils-1.2.4
Message-ID: <20101011151615.30cbefd3@notabene>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 10 Oct 2010 20:04:01 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Steve-
> 
> Here are fifteen patches which address several mount and mountd bugs
> and correct other minor problems in nfs-utils-1.2.3.  Now that the
> bake-a-thon event has passed, folks should have some spare moments to
> review these.

Hi,
 here is another you might like to add to the list.

gcc complained:

client.c: In function 'init_netmask6':
client.c:181:1: warning: no return statement in function returning non-void

and Suse' build system complained

I: Program returns random data in a function
E: nfs-utils no-return-in-nonvoid-function client.c:181

when I built without --enable-ipv6


Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/support/export/client.c b/support/export/client.c
index dbfc2b1..ba2db8f 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -178,6 +178,7 @@ out_badprefix:
 static int
 init_netmask6(nfs_client *UNUSED(clp), const char *UNUSED(slash))
 {
+	return 0;
 }
 #endif	/* IPV6_SUPPORTED */
 
