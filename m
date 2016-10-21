Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43476 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933352AbcJUPxb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 11:53:31 -0400
Date: Fri, 21 Oct 2016 11:53:29 -0400
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'J. Bruce Fields'" <bfields@redhat.com>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
Subject: Re: pynfs pull request
Message-ID: <20161021155329.GA19831@fieldses.org>
References: <037201d1e81e$04a9b9f0$0dfd2dd0$@mindspring.com>
 <20160728193855.GF4732@pad>
 <040401d1e914$52e71a30$f8b54e90$@mindspring.com>
 <20160729213011.GA11390@pad>
 <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <047b01d1e9e3$e6d51fb0$b47f5f10$@mindspring.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2016 at 02:55:19PM -0700, Frank Filz wrote:
> > On Thu, Jul 28, 2016 at 02:09:26PM -0700, Frank Filz wrote:
> > > Pull master branch from: git://github.com/ffilz/pynfs.git
> > >
> > > 6c6ecec ajay nair Added WRT19 to check WRITE operation with incorrect
> > > permissions and somebody else's stateid 03f0aee Frank S. Filz Add
> > > WRT18 to test 4 writes in single compound updates change each time
> > > 2fe404f Frank S. Filz Make ACL tests check for support of FATTR4_ACL

By the way, Kaleb just noticed that the sense of ACL0 is reversed--it
fails when ACLs are supported.  I've added the missing "not".

--b.
