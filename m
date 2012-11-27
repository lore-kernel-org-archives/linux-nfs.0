Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755183Ab2K0Vb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 16:31:29 -0500
Date: Tue, 27 Nov 2012 16:31:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in
 auth_unix_ip upcall"
Message-ID: <20121127213127.GH27142@fieldses.org>
References: <20121126220343.GA18140@fieldses.org>
 <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com>
 <20121126221535.GB18186@fieldses.org>
 <A954A569-E030-4119-A349-6CB888979738@oracle.com>
 <20121126225116.GE18186@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121126225116.GE18186@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 05:51:16PM -0500, J. Bruce Fields wrote:
> On Mon, Nov 26, 2012 at 05:38:49PM -0500, Chuck Lever wrote:
> > What exactly is the problem with the current code?
> > 
> > client_resolve() can return a NULL in some cases.  Why is it OK to
> > pass a NULL "ai" to client_compose() ?  Looks like that can result in
> > a mountd segfault.
> 
> Bah, I thought I'd checked this and found it was prepared to handle
> that, but no:
> 
> 	client_check->check_wildcard()
> 
> looks like it can oops.

Right, so the real problem is just that we're skipping the downcall on
failure instead of responding with a negative cache entry.  Thus we're
leaving the client hanging instead of returning an error.

So, I suppose we should do the below, based on steved's suggestion
(compiled, otherwise untested).

--b.

commit dfb31d861261c8461a2dc4fb7e8823f5169a9079
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Nov 27 16:10:41 2012 -0500

    mountd: auth_unix_ip should downcall on error to prevent hangs
    
    Since bf6a4febaa78bf188896b7b5b02c46562dd08b70 "mountd: handle
    allocation failures in auth_unix_ip upcall", a failure to map the
    address of an incoming client to a name could result in a hang.
    
    We should be responding with an error in the case, not just skipping the
    downcall and leaving everybody hanging.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index e950ec6..c13f305 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -109,12 +109,10 @@ static void auth_unix_ip(FILE *f)
 		struct addrinfo *ai = NULL;
 
 		ai = client_resolve(tmp->ai_addr);
-		if (ai == NULL)
-			goto out;
-		client = client_compose(ai);
-		freeaddrinfo(ai);
-		if (!client)
-			goto out;
+		if (ai) {
+			client = client_compose(ai);
+			freeaddrinfo(ai);
+		}
 	}
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
@@ -127,7 +125,6 @@ static void auth_unix_ip(FILE *f)
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
 	free(client);
-out:
 	freeaddrinfo(tmp);
 
 }
