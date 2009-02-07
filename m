From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sat, 7 Feb 2009 18:56:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
References: <20090206.140714.201930500.davem@davemloft.net>
 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
 <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-629966607-1234025763=:2805"
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	chuck.lever@oracle.com, bfields@fieldses.org, trond@netapp.com,
	linux-nfs@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49354 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbZBGQ4G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Feb 2009 11:56:06 -0500
In-Reply-To: <1234023804.17241.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-629966607-1234025763=:2805
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 7 Feb 2009, Trond Myklebust wrote:

> On Fri, 2009-02-06 at 19:22 -0800, David Miller wrote:
> > From: "Ilpo Järvinen" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
> > Date: Sat, 7 Feb 2009 00:58:44 +0200 (EET)
> > 
> > > I think your "English" is too strict requirement.
> > 
> > I absolutely and whole-heartedly agree.  This set of
> > requirements is beyond rediculious and will do nothing
> > but deter people from contributing.
> > 
> > So unless that's what the goal is...
> > 
> > Anyways, I'll be applying Ilpo's great changes to the
> > net-next-2.6 GIT tree, without putting him through the
> > ringer like this.
> 
> No. I find it quite unacceptable for the networking group to circumvent
> the standard Linux review process in this manner. If you plan to push a
> patch into the sunrpc code against the wishes of the community and
> people that maintain that code then I'll be petitioning Linus to revert
> it on general principle as soon as it hits his tree.

:-)

> Like it or not, the changelog _is_ a part of the patch that is subject
> to review and comment, and while I like the rest of the patch, I will
> support Chuck and Bruce's comments that putting a bunch of diffstat
> output into the changelog is not a substitute for a simple sentence.

But this is likely based on a false assumption (see my thought about that
below), and I didn't have diffstat afaik :-).

> All it takes is
> 
> "
> Save 147 lines by moving the common code from xs_udp_write_space() and
> xs_tcp_write_space() into a separate helper.
> 
> S-o-b: Ilpo....
> "

Can you please tell if you're still under impression that there wasn't
any changelog? What about those other guys who raised their concerns?
(I can certainly understand why this impression might develop but it's a 
problem in the canonial patch format, not in my actual changelog, I even 
need to circumvent ^--- by adding a space the to prevent tools for making 
a mistake). It will make a lot more sense after getting applied.
...Because there certainly was a changelog, and I didn't have any 
diffstat output there in the changelog?!? The output that *is* in the 
changelog is supposed to *help* the reviewer to see what will be still 
necessary to keep in the separate functions, but I guess people missed 
that because the changelog looks too similar to what you will categorize 
as patch (diff-funcs uses output which is familiar to all who who deal 
with patches, and that's for purpose!).

> and everyone will be happy. So please stop making a storm in a teacup
> out of this...

I even tried to make sunrpc people happy by sending the followup with some 
plain English in changelog too (though it seems very obvious as you could 
spell it out above without a question besides the s/bytes/lines/ :-)) and
even more clear title. I agree that I should have put, "; add helper" or
something like that to the title which is exactly what I did in the 
followup.

I personally think that people were honestly just mislead to think that 
diff-funcs output is part of the patch -> thus it raises complaining 
about missing changelog (which is not true).

But whatever :-). Feel free to revert the first one and put the followup 
which has something to satisfy all :-).

-- 
 i.
---696208474-629966607-1234025763=:2805--
