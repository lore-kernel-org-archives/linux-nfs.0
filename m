Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:60839 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298Ab1IFN7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Sep 2011 09:59:43 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <1315302066.2741.12.camel@menhir>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315302066.2741.12.camel@menhir>
Date: Tue, 06 Sep 2011 19:28:51 +0530
Message-ID: <87obyxdb6s.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 06 Sep 2011 10:41:06 +0100, Steven Whitehouse <swhiteho@redhat.com> wrote:
> Hi,
> 
> On Mon, 2011-09-05 at 22:55 +0530, Aneesh Kumar K.V wrote:
> > Hi,
> > 
> > The following set of patches implements VFS and ext4 changes needed to implement
> > a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> > extended by file masks to fit into the standard POSIX file permission model.
> > They are designed to work seamlessly locally as well as across the NFSv4 and
> > CIFS/SMB2 network file system protocols.
> > 
> > A user-space utility for displaying and changing richacls is available at [4]
> > (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
> > 
> > [4] git://git.kernel.org/pub/scm/fs/acl/kvaneesh/richacl.git master
> > 
> > To test richacl on ext4 use -o richacl mount option. This mount option may later be
> > dropped in favour of a feature flag.
> > 
> > More details regarding richacl can be found at
> > http://acl.bestbits.at/richacl/
> > 
> > Changes from v5:
> > a) rebase to v3.1-rc4-131-g9e79e3e
> > 
> > NOTE: The kernel changes will be pushed to
> > git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/linux-richacl.git richacl
> > when kernel.org is back
> > 
> > -aneesh
> > 
> 
> This looks like a really nice patch set. One question though is whether
> there are any test suites which can be used to gain confidence in the
> implementation? Obviously there is a fair amount of change here which
> has security implications, so it would be good to have some test results
> to go along with the patches,

You can find the tests at 

http://git.kernel.org/?p=fs/acl/kvaneesh/richacl.git;a=tree;f=test;h=3bedf00ac69c79ae7a433996e729d4afb366b229;hb=HEAD

-aneesh
