Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:52103
        "EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752030AbcJXSNa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2016 14:13:30 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: "'J. Bruce Fields'" <bfields@redhat.com>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com> <20160728193855.GF4732@pad> <040401d1e914$52e71a30$f8b54e90$@mindspring.com> <20160729213011.GA11390@pad> <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com> <20161021155329.GA19831@fieldses.org>
In-Reply-To: <20161021155329.GA19831@fieldses.org>
Subject: RE: pynfs pull request
Date: Mon, 24 Oct 2016 11:02:55 -0700
Message-ID: <00bd01d22e20$d8f80610$8ae81230$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, Jul 29, 2016 at 02:55:19PM -0700, Frank Filz wrote:
> > > On Thu, Jul 28, 2016 at 02:09:26PM -0700, Frank Filz wrote:
> > > > Pull master branch from: git://github.com/ffilz/pynfs.git
> > > >
> > > > 6c6ecec ajay nair Added WRT19 to check WRITE operation with
> > > > incorrect permissions and somebody else's stateid 03f0aee Frank S.
> > > > Filz Add
> > > > WRT18 to test 4 writes in single compound updates change each time
> > > > 2fe404f Frank S. Filz Make ACL tests check for support of
> > > > FATTR4_ACL
> 
> By the way, Kaleb just noticed that the sense of ACL0 is reversed--it
fails
> when ACLs are supported.  I've added the missing "not".

Yea, sorry...

The test "works" for me because Ganesha always advertises ACL support even
when a given filesystem doesn't (either because ACLs aren't enabled on it,
or the FSAL doesn't support ACLs at all). Since my testing is all on
environments that don't support ACLs, it appears to give correct results,
none of the other ACL tests run, and thus they list as omitted rather than
as failures...

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

