From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Wed, 2 Apr 2008 16:06:14 -0700
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C59D3BD9@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local> <20080401210627.GD21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3777@exchange.ZeugmaSystems.local> <20080401221327.GH21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3A6C@exchange.ZeugmaSystems.local> <DDFD17CC94A9BD49A82147DDF7D545C59D3B32@exchange.ZeugmaSystems.local> <20080402222611.GC16302@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "J. Bruce Fields" <bfields@fieldses.org>,
	<linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:25422 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756203AbYDBXGy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2008 19:06:54 -0400
In-Reply-To: <20080402222611.GC16302@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>
>>
>> Indeed. Actually, by mistake, I was using the new 1.1.2 nfs-utils
>> binaries and making changes in the old 1.1.0 nfs-utils source. The
>> removal of the member does not change anything. What is happening is
>> that an upgrade to the new 1.1.2 nfs-utils binaries solves the
>problem.
>> I think you can reproduce the problem at your end simply by
unmounting
>> nfsd filesystem and using 1.1.0 nfs-utils binary.
>
>OK!  Hm, do you know which patch actually fixed this?  (Is it actually
>just the same problem you reported before?)  

No, it can't be the same patch. After I reported the issue and Neil gave
me the patch, I applied the patch to our own nfs-utils source and
thereafter, our build process has been using the patched nfs-utils
binaries ever since. However, interestingly, the patch that was
committed to the git repo is handles the issue slightly differently
(though I think it should not create any difference).

The patch Neil gave me is as follows:

diff --git a/support/export/client.c b/support/export/client.c
index 1cb242f..e96f5e0 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -462,5 +462,5 @@ client_gettype(char *ident)
 	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
'.') return MCL_FQDN;
 	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
'\0') return MCL_FQDN;
 	/* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :)
*/
-	return MCL_SUBNETWORK;
+	return MCL_FQDN;
 } 


On a quick skim through the
>git history I'm not seeing it.

Hmm, I also did a quick skip through the commit logs. Didn't quite see
anything that might be relevant. However, I retested with 1.1.2 and
again it *did* solve the issue. Interesting! 


A


>
>--b.
