Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:35805 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbcG1VJj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2016 17:09:39 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@redhat.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com> <20160728193855.GF4732@pad>
In-Reply-To: <20160728193855.GF4732@pad>
Subject: RE: pynfs pull request
Date: Thu, 28 Jul 2016 14:09:26 -0700
Message-ID: <040401d1e914$52e71a30$f8b54e90$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Jul 27, 2016 at 08:46:18AM -0700, Frank Filz wrote:
> > Bruce, could you pull:
> >
> > https://github.com/ffilz/pynfs/commits/master
> >
> > Also, Ajay submitted a pull request to me
> >
> > https://github.com/ffilz/pynfs/pull/1
> >
> > Could you pull that also (or would you prefer I merge it into my
> > branch and then have you pull everything from my branch)?
> 
> I'm fine either way, but would you mind just giving me a git:// url to
pull
> from?  I mean, I assume I can track down the repo url's from the github
url's
> and pull from master in each, but it'd be simpler for me in future and I'd
be
> sure I was getting what you intended....
> 
> And a cc: to linux-nfs with the pull requests would be useful too.  I
don't think
> anyone else reviews those, but maybe somebody will some day.

Ok, I merged Ajay's patch (had to replace a checklist with check) and
verified the test fails without the Ganesha fix and succeeds with, so looks
like a good test case addition.

Pull master branch from: git://github.com/ffilz/pynfs.git

6c6ecec ajay nair Added WRT19 to check WRITE operation with incorrect
permissions and somebody else's stateid
03f0aee Frank S. Filz Add WRT18 to test 4 writes in single compound updates
change each time
2fe404f Frank S. Filz Make ACL tests check for support of FATTR4_ACL
2750cbd Frank S. Filz Add ganesha flag to tests that Ganesha passes

Thanks

Frank



---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

