Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42010 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751749AbeDCOsk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Apr 2018 10:48:40 -0400
Date: Tue, 3 Apr 2018 10:48:40 -0400
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, fstests@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Message-ID: <20180403144840.GA20297@fieldses.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
 <20180403094540.GA2254@infradead.org>
 <DA98114C-755B-4DA2-B188-3C6E27A44E93@redhat.com>
 <20180403122531.GA30598@infradead.org>
 <5987BE75-EB3E-48CA-8968-92EBC962435C@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5987BE75-EB3E-48CA-8968-92EBC962435C@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 03, 2018 at 08:36:35AM -0400, Benjamin Coddington wrote:
> On 3 Apr 2018, at 8:25, Christoph Hellwig wrote:
> 
> > On Tue, Apr 03, 2018 at 08:10:36AM -0400, Benjamin Coddington wrote:
> >> No, having nlink == 1 is not a bug and we should expect that behavior, the
> >> same with the -ESTALE return for a directory.  This is true, at least, for
> >> the linux client.
> >
> > In terms of Linux semantics is plain and simple is a bug.  It is an
> > expected bug in NFS, but that doesn't make it correct.
> 
> Ok yes.  I'd still like to test for it, since it's possible we can get this
> wrong.

In the regular file case this is fixable with current protocol[1].

If/when we fix this then we'll want a test like this one to verify the
fix.  So I think I'm won over to Christoph's point of view here.

Agreed that it'd be nice to have expected failures reported separately
somehow, though, as sorting through this kind of thing is an obstacle to
new NFS developers starting with xfstests.

--b.

[1] Grep for "OPEN4_RESULT_PRESERVE_UNLINKED" in RFC 5661.  NFSv4 opens
can already hold a reference to an unlinked file, the remaining work is
to figure out how to persist that across server reboot.  Maybe we'd do a
sillyrename server-side into a hidden directory and fix up nlink to hide
the extra link in this case.  Then we'd need to teach the client to stop
doing sillyrename when the PRESERVE_UNLINKED flag is set.
