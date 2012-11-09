Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45493 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab2KIXRm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 18:17:42 -0500
Received: by mail-bk0-f46.google.com with SMTP id jk13so1834471bkc.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 15:17:40 -0800 (PST)
Date: Sat, 10 Nov 2012 00:17:33 +0100 (CET)
From: Eldad Zack <eldad@fogrefinery.com>
To: Sven Geggus <lists@fuchsschwanzdomain.de>,
        "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
In-Reply-To: <20121109200730.GI6171@fieldses.org>
Message-ID: <alpine.LNX.2.00.1211100000470.1173@xoschi>
References: <k6ebva$1kf$1@ultimate100.geggus.net> <20121026171549.GA11806@fieldses.org> <20121029094038.GA14836@geggus.net> <20121029150203.GB9502@fieldses.org> <20121105165459.GA2958@geggus.net> <k7jj0c$nak$1@ultimate100.geggus.net>
 <20121109200730.GI6171@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 9 Nov 2012, J. Bruce Fields wrote:
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

Uh oh. Sorry about that.
This might help pinpoint the problem - have simple_strto* WARN
(or WARN_ONCE maybe?) just before masking out the overflow.

I'm running with this now and so far I get no warnings.

Cheers,
Eldad

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index c56de78..8a748c6 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -49,6 +49,8 @@ unsigned long long simple_strtoull(const char *cp, char **endp, unsigned int bas
 	cp = _parse_integer_fixup_radix(cp, &base);
 	rv = _parse_integer(cp, base, &result);
 	/* FIXME */
+	WARN((rv & KSTRTOX_OVERFLOW) == KSTRTOX_OVERFLOW,
+		"simple_strtox overflow while parsing '%s' (base %d)\n", cp, base);
 	cp += (rv & ~KSTRTOX_OVERFLOW);
 
 	if (endp)




