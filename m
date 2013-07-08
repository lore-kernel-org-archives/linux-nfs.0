Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55761 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab3GHTlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 15:41:46 -0400
Date: Mon, 8 Jul 2013 15:41:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130708194144.GG29071@fieldses.org>
References: <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
 <20130702080530.GA17953@geggus.net>
 <20130705181859.GA8288@fieldses.org>
 <20130705203435.GE8288@fieldses.org>
 <20130708080803.GB29990@geggus.net>
 <20130708133537.GA29071@fieldses.org>
 <20130708155406.GA7808@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130708155406.GA7808@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 08, 2013 at 05:54:06PM +0200, Sven Geggus wrote:
> J. Bruce Fields schrieb am Montag, den 08. Juli um 15:35 Uhr:
> 
> > Anyway.  OK, that more or less solves the mystery, though the strace
> > output might still be interesting.
> 
> Not very enlightening, at least for me, but here we go:
> 
> read(3, "nfsd 10.1.7.30\n", 2048)       = 15
> close(13)                               = 0
> open("/var/lib/nfs/etab", O_RDONLY)     = 13
> close(13)                               = 0
> close(13)                               = 0
> write(3, "nfsd 10.1.7.30 1373300439 * \n", 29) = 29
> read(4, "4294967295\n", 2048)           = 11
> close(14)                               = 0
> close(13)                               = 0
> read(13, "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0", 36) = 36
> close(13)                               = 0
> write(4, "4294967295 1373300439 0 \n", 25) = -1 EINVAL (Invalid argument)

Thanks!  Yep, 4294967295 is (u32)(-1), so it's this uid_valid check in
unix_gid_parse that we're hitting.

I'm not even sure whether it makes sense to be doing this upcall to ask
for supplemental groups in the -1 case.  Going with the minimal fix for
now.

Oh, and oops, it should go to stable to--adding that Cc: to my local
copy of the patch.

--b.

commit 8efb88340e29293e05f6b498b60596884c05a8a8
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jul 8 13:44:45 2013 -0400

    svcrpc: fix failures to handle -1 uid's
    
    As of f025adf191924e3a75ce80e130afcd2485b53bb8 "sunrpc: Properly decode
    kuids and kgids in RPC_AUTH_UNIX credentials" any rpc containing a -1
    (0xffff) uid or gid would fail with a badcred error.
    
    Commit afe3c3fd5392b2f0066930abc5dbd3f4b14a0f13 "svcrpc: fix failures to
    handle -1 uid's and gid's" fixed part of the problem, but overlooked the
    gid upcall--the kernel can request supplementary gid's for the -1 uid,
    but mountd's attempt write a response will get -EINVAL.
    
    Symptoms were nfsd failing to reply to the first attempt to use a newly
    negotiated krb5 context.
    
    Reported-by: Sven Geggus <lists@fuchsschwanzdomain.de>
    Tested-by: Sven Geggus <lists@fuchsschwanzdomain.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index a98853d..621ca7b 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -493,8 +493,6 @@ static int unix_gid_parse(struct cache_detail *cd,
 	if (rv)
 		return -EINVAL;
 	uid = make_kuid(&init_user_ns, id);
-	if (!uid_valid(uid))
-		return -EINVAL;
 	ug.uid = uid;
 
 	expiry = get_expiry(&mesg);
