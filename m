Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44730 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750859AbeCICqA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 21:46:00 -0500
Date: Thu, 8 Mar 2018 21:46:00 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "smayhew@redhat.com" <smayhew@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Message-ID: <20180309024600.GA20826@fieldses.org>
References: <20180302160038.1598-1-smayhew@redhat.com>
 <20180305211619.GA29226@fieldses.org>
 <1520286491.21829.13.camel@primarydata.com>
 <20180307195313.kzqdboqk5j2hyrf3@tonberry.usersys.redhat.com>
 <1520455098.2858.4.camel@primarydata.com>
 <20180308130901.h2qbbzsuejggogut@tonberry.usersys.redhat.com>
 <20180308213904.GD16485@fieldses.org>
 <1520546500.91818.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1520546500.91818.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 08, 2018 at 10:01:42PM +0000, Trond Myklebust wrote:
> On Thu, 2018-03-08 at 16:39 -0500, bfields@fieldses.org wrote:
> > On Thu, Mar 08, 2018 at 08:09:01AM -0500, Scott Mayhew wrote:
> > > Yes, this works.  I ran it through a dozen fio runs on v4.1 and
> > > 1000 runs
> > > of generic/247 on v3/v4.0/v4.1/v4.2 and didn't see any EBUSY
> > > errors.
> > > Also ran the xfstests "quick" group (~80-90 tests) plus generic/074
> > > on
> > > v3/v4.0/v4.1/v4.2.  Finally, I double checked the panic on umount
> > > issue
> > > that dc4fd9ab01ab3 fixed and that still works too.
> > 
> > Works for me too.
> > 
> > (Yeah, I see there's a new patch.  Testing queued up but not run
> > yet...).
> 
> Sorry for pulling the "new patch switch" on you both, but I figured it
> would be better to re-examine where the requirement for the dirty flag
> is coming from, and to ensure that we meet that requirement once and
> for all.

No problem.  My tests are passing on the new patch as well.

--b.
