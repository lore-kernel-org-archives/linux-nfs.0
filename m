Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbcG2VaO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 17:30:14 -0400
Date: Fri, 29 Jul 2016 17:30:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
Subject: Re: pynfs pull request
Message-ID: <20160729213011.GA11390@pad>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com>
 <20160728193855.GF4732@pad>
 <040401d1e914$52e71a30$f8b54e90$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <040401d1e914$52e71a30$f8b54e90$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 28, 2016 at 02:09:26PM -0700, Frank Filz wrote:
> > On Wed, Jul 27, 2016 at 08:46:18AM -0700, Frank Filz wrote:
> > > Bruce, could you pull:
> > >
> > > https://github.com/ffilz/pynfs/commits/master
> > >
> > > Also, Ajay submitted a pull request to me
> > >
> > > https://github.com/ffilz/pynfs/pull/1
> > >
> > > Could you pull that also (or would you prefer I merge it into my
> > > branch and then have you pull everything from my branch)?
> > 
> > I'm fine either way, but would you mind just giving me a git:// url to
> pull
> > from?  I mean, I assume I can track down the repo url's from the github
> url's
> > and pull from master in each, but it'd be simpler for me in future and I'd
> be
> > sure I was getting what you intended....
> > 
> > And a cc: to linux-nfs with the pull requests would be useful too.  I
> don't think
> > anyone else reviews those, but maybe somebody will some day.
> 
> Ok, I merged Ajay's patch (had to replace a checklist with check) and
> verified the test fails without the Ganesha fix and succeeds with, so looks
> like a good test case addition.

Thanks!

> 
> Pull master branch from: git://github.com/ffilz/pynfs.git
> 
> 6c6ecec ajay nair Added WRT19 to check WRITE operation with incorrect
> permissions and somebody else's stateid
> 03f0aee Frank S. Filz Add WRT18 to test 4 writes in single compound updates
> change each time
> 2fe404f Frank S. Filz Make ACL tests check for support of FATTR4_ACL
> 2750cbd Frank S. Filz Add ganesha flag to tests that Ganesha passes

So, those are tests beyond those in "all", that Ganesha passes?  OK.  I
could try to claim pynfs shouldn't be the place for server-dependent
information, but this isn't the first, and I can see how it's convenient
and I don't see it as a problem at least for now.

The reason knfsd gave up on the utf8 tests was complaints from people
with filesystems with non-utf8 encodings.  Given a preexisting
filesystem neither knfsd nor probably Ganesha has any way to determine
the encoding, so we're left just injecting unhelpful errors when we come
across something that doesn't look like utf-8.  Which just annoyed
people with those filesystems, didn't really help anyone else, and
changed behavior on NFSv3->NFSv4 upgrade.

But maybe non-utf8 is less common now.

Anyway, patches look fine, applying.

--b.
