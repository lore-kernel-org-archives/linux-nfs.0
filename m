Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755761Ab2KIUJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 15:09:58 -0500
Date: Fri, 9 Nov 2012 15:09:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121109200957.GJ6171@fieldses.org>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
 <20121026171549.GA11806@fieldses.org>
 <20121029094038.GA14836@geggus.net>
 <20121029150203.GB9502@fieldses.org>
 <20121105165459.GA2958@geggus.net>
 <k7jj0c$nak$1@ultimate100.geggus.net>
 <20121109200730.GI6171@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121109200730.GI6171@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 09, 2012 at 03:07:30PM -0500, bfields wrote:
> On Fri, Nov 09, 2012 at 06:45:32PM +0000, Sven Geggus wrote:
> > Sven Geggus <lists@fuchsschwanzdomain.de> wrote:
> > 
> > > OK, I now figured out which commit did cause the problem:
> > > 
> > > Thus "git diff 08843b79..cc8362b1" on a linux-stable tree from
> > > git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git should
> > > give us the relevant changes.
> > 
> > After a private conversation with J. Bruce Fields I figured out that
> > I have not been quite there yet. So here comes a FTR post what
> > exactly caused my problem.
> 
> Thanks for tracking this down--not what I would have guessed!
> 
> Given that the trace showed a problem starting around context creation
> time, I'm most suspicious of the callers in rsc_parse, which are mostly
> parsing uid's.
> 
> Is it possible that your system has very large uid's?  (Large enough
> that they'd look like negative numbers when cast to ints?)
> 
> Output from
> 
> 	strace -p $(pidof rpc.mountd) -s4096 -e trace=open,close,read,write
> 
> (while reproducing the bug) might help confirm that.

And this might help.

--b.

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index ec76f3a..31b4e95 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -430,7 +430,7 @@ static int rsc_parse(struct cache_detail *cd,
 		goto out;
 
 	/* uid, or NEGATIVE */
-	rv = get_int(&mesg, &rsci.cred.cr_uid);
+	rv = get_uint(&mesg, &rsci.cred.cr_uid);
 	if (rv == -EINVAL)
 		goto out;
 	if (rv == -ENOENT)
@@ -439,7 +439,7 @@ static int rsc_parse(struct cache_detail *cd,
 		int N, i;
 
 		/* gid */
-		if (get_int(&mesg, &rsci.cred.cr_gid))
+		if (get_uint(&mesg, &rsci.cred.cr_gid))
 			goto out;
 
 		/* number of additional gid's */
@@ -455,7 +455,7 @@ static int rsc_parse(struct cache_detail *cd,
 		for (i=0; i<N; i++) {
 			gid_t gid;
 			kgid_t kgid;
-			if (get_int(&mesg, &gid))
+			if (get_uint(&mesg, &gid))
 				goto out;
 			kgid = make_kgid(&init_user_ns, gid);
 			if (!gid_valid(kgid))
