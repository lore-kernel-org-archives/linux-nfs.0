Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:25449 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbBXPe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2015 10:34:29 -0500
Date: Tue, 24 Feb 2015 18:34:01 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jeff Layton <jlayton@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch v2] sunrpc: integer underflow in rsc_parse()
Message-ID: <20150224153401.GA12218@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150223211607.GB28635@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we call groups_alloc() with invalid values then it's might lead to
memory corruption.  For example, with a negative value then we might not
allocate enough for sizeof(struct group_info).

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2:  In v1, I changed groups_alloc().  The other places which call
groups_alloc() check the value before calling.  Eric wanted that, either
have all the callers check, or all the callers rely on groups_alloc().
In the end, Bruce Fields said adding the check here was probably
reasonable.

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 224a82f..1095be9 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -463,6 +463,8 @@ static int rsc_parse(struct cache_detail *cd,
 		/* number of additional gid's */
 		if (get_int(&mesg, &N))
 			goto out;
+		if (N < 0 || N > NGROUPS_MAX)
+			goto out;
 		status = -ENOMEM;
 		rsci.cred.cr_group_info = groups_alloc(N);
 		if (rsci.cred.cr_group_info == NULL)
