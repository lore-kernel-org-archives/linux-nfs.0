Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:52206 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751451AbcG2Vze (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2016 17:55:34 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@redhat.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com> <20160728193855.GF4732@pad> <040401d1e914$52e71a30$f8b54e90$@mindspring.com> <20160729213011.GA11390@pad>
In-Reply-To: <20160729213011.GA11390@pad>
Subject: RE: pynfs pull request
Date: Fri, 29 Jul 2016 14:55:19 -0700
Message-ID: <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Thu, Jul 28, 2016 at 02:09:26PM -0700, Frank Filz wrote:
> > > On Wed, Jul 27, 2016 at 08:46:18AM -0700, Frank Filz wrote:
> > > > Bruce, could you pull:
> > > >
> > > > https://github.com/ffilz/pynfs/commits/master
> > > >
> > > > Also, Ajay submitted a pull request to me
> > > >
> > > > https://github.com/ffilz/pynfs/pull/1
> > > >
> > > > Could you pull that also (or would you prefer I merge it into my
> > > > branch and then have you pull everything from my branch)?
> > >
> > > I'm fine either way, but would you mind just giving me a git:// url
> > > to
> > pull
> > > from?  I mean, I assume I can track down the repo url's from the
> > > github
> > url's
> > > and pull from master in each, but it'd be simpler for me in future
> > > and I'd
> > be
> > > sure I was getting what you intended....
> > >
> > > And a cc: to linux-nfs with the pull requests would be useful too.
> > > I
> > don't think
> > > anyone else reviews those, but maybe somebody will some day.
> >
> > Ok, I merged Ajay's patch (had to replace a checklist with check) and
> > verified the test fails without the Ganesha fix and succeeds with, so
> > looks like a good test case addition.
> 
> Thanks!
> 
> >
> > Pull master branch from: git://github.com/ffilz/pynfs.git
> >
> > 6c6ecec ajay nair Added WRT19 to check WRITE operation with incorrect
> > permissions and somebody else's stateid 03f0aee Frank S. Filz Add
> > WRT18 to test 4 writes in single compound updates change each time
> > 2fe404f Frank S. Filz Make ACL tests check for support of FATTR4_ACL
> > 2750cbd Frank S. Filz Add ganesha flag to tests that Ganesha passes
> 
> So, those are tests beyond those in "all", that Ganesha passes?  OK.  I
could
> try to claim pynfs shouldn't be the place for server-dependent
information,
> but this isn't the first, and I can see how it's convenient and I don't
see it as a
> problem at least for now.

There are a few ganesha specific tests. Some are where it needs to form a
bad stateid. These are useful tests for servers, but obviously need to be
server specific. The rest are tests that are not part of all but it's handy
to document the ones Ganesha is expected to pass (and makes it easier for me
to instruct QA folks which tests to run.. run all ganesha... otherwise they
only run all...).

Maybe down the road it would be nice to have a better way of specifying what
tests should be run for certain servers so rather than having the ganesha
flag on a bunch of tests, there is some single file we list additional tests
to be added to the "all" bucket if some flag indicating ganesha is specified
on the command line. Such a mechanism could even add the tests to various
flags (so for example, any lock tests Ganesha passes would be added to the
all AND lock flags).

I'd love to see evidence that other servers are considering pynfs for spec
validation testing...

> The reason knfsd gave up on the utf8 tests was complaints from people with
> filesystems with non-utf8 encodings.  Given a preexisting filesystem
neither
> knfsd nor probably Ganesha has any way to determine the encoding, so
> we're left just injecting unhelpful errors when we come across something
> that doesn't look like utf-8.  Which just annoyed people with those
> filesystems, didn't really help anyone else, and changed behavior on
NFSv3-
> >NFSv4 upgrade.
> 
> But maybe non-utf8 is less common now.

Hmm, I can see that point. It would be interesting to see if we could just
lump utf8 tests into all now...

> Anyway, patches look fine, applying.

Glad you also picked up the additional patch I added today with the exit
code on failed tests. Hmm, that change actually probably should be made to
nfs4.1/testserver.py also...

Thanks

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

