From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Tue, 10 Feb 2009 15:12:37 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902101417550.31742@wrl-59.cs.helsinki.fi>
References: <20090206.140714.201930500.davem@davemloft.net>
 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
 <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org>
 <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
 <20090208052543.GA20689@fieldses.org> <9A7C762F-D2D4-4248-B18A-5FAB973D22A6@oracle.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2038977359-1234271557=:31742"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Trond Myklebust <trond@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <9A7C762F-D2D4-4248-B18A-5FAB973D22A6@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2038977359-1234271557=:31742
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 9 Feb 2009, Chuck Lever wrote:

> On Feb 8, 2009, at 12:25 AM, J. Bruce Fields wrote:
> >On Sat, Feb 07, 2009 at 06:56:03PM +0200, Ilpo Järvinen wrote:
> > >I personally think that people were honestly just mislead to think that
> > >diff-funcs output is part of the patch
> >
> >Yes, exactly, in my case, that's all it was--the "diff" I thought I saw
> >in my 2-second skim looked odd, and I figured a comment might have
> >gotten dropped off in the process of replying and adding cc's--hence the
> >original question.
> 
> I apologize if my request for "English" seemed Anglo-centric.  What I intended
> was "non-machine-generated" and expressed in the natural language that is
> usual for Linux kernel patch descriptions, which appears to be English.

...I still argue that if title gives the same information as that 
sentence would, the sentence is optional. Some patches don't even have 
patch description beyond title and there's very little problem with that. 
As I admitted earlier the title wasn't as good as it should have (and I 
even sent a followup to please all including even the in body sentence 
plus the fixed title). Not that I find the title really a problem to sane 
people who understand that code-duplication is bad and getting rid of it 
is what one should do in general, as long as it's possible without making 
a mess out of it.

> I agree with you that the diff output in the patch description was confusing,
> and yes, after Dave's first comment I understood what the description meant.
> I believe patch authors owe it to maintainers, who have dozens of patches to
> review a day, to keep it as simple and easy as possible.  I have tried to work
> with individual maintainers where possible to improve the legibility of my
> patches, though at times I have fallen short.
> 
> Although interesting, the tool output doesn't seem necessary to justify the
> proposed change.

I don't understand why a tool output cannot "say" the same as some English 
sentence... And if a proof that the code blocks that were merged were 
infact identical (instead of having some hard to spot difference) doesn't 
seem like useful information to reviewer I don't really know what to say.

> In addition to crafting a legible description, my suggestions were about
> cc'ing the proper mailing list, and routing this patch directly to the sunrpc
> kernel maintainers in the first place, all of which are listed within easy
> reach in MAINTAINERS.

Please note that I couldn't guess that I'd have to look for another entry 
after first SUNRPC entry in the MAINTAINERS. So asking outsider to know
who is who in sunrpc realm is not very likely to be a practical 
requirement either. And even to add into confusion the latest commits 
in that particular directory had the last S-o-B line as Bruce's. How could 
I have guessed? Forgetting to lookup the address from MAINTAINERS into the 
first mail is something which just happened and I'm certainly guilty to 
that :-).

...I've had enough down turning experiences with random dev lists listed 
in the MAINTAINERS (mostly spammy subsriber only ones, nearly infinite 
response time, etc things) that I mostly ignore them nowadays though this 
time it would have been vger list so no subscription required madness. 
Instead I either select lkml or netdev, this time netdev because of 
the obvious presence under net/ hierarcy.

> But I wonder how we ended up with these two copies of the same logic.  It may
> be that at some point in the past we had more different logic in the two
> write_space functions, but I suppose we can split it out again if we ever need
> to.  Thinking aloud, at some point we may have lost a little history here, or
> we may have perhaps lost any implicit operational dependencies on other parts
> of xprtsock.c (like the TCP state logic) that are not expressed in the source
> code or comments.

Well, this kind of thinking is beyond me and requires more knowledge about 
internals of the code. IMHO, this kind of speculation changes nothing 
really, and besides the functions _were_ different to begin with as was
proven in the patch description :-). ...Would they have been fully 
identical you would have seen a bit different patch ;-).

If you think there's something wrong, please fix, you're free to do so,
I don't understand enough. But we don't keep all those #if 0 blocks 
around either just because somebody thinks that something will get 
implemented one day (not that you directly made such assertion, probably 
saying mildy the opposite instead). Ironically, you would have been 
perfectly happy with the particular functions unless a cleanup patch 
against them gets made... :-)

> The newly shared code appears to be socket-specific, so it does not 
> belong in the shared function we already have, xprt_write_space(), which 
> is meant to be transport-generic.

IMHO, this is the most useful response so far! :-) Usually the hardest 
obstacles I face with non-familiar code is its structure and naming.


-- 
 i.
---696208474-2038977359-1234271557=:31742--
