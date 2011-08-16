Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33699 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab1HPLDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 07:03:24 -0400
Date: Tue, 16 Aug 2011 07:03:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, nfsv4@ietf.org
Subject: Re: open() of device special files
Message-ID: <20110816110322.GC5829@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110815212539.GA32181@fieldses.org>
 <20110815222336.GB32181@fieldses.org>
 <20110815222721.GC32181@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9BE53@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9BE53@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 10:04:29PM -0700, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > And the change also makes a bunch of pynfs tests fail, complaining
> that
> > various operations against incompatible types should have returned
> > INVAL
> > and not SYMLINK.
> > 
> > Not that I'm convinced pynfs is correct--at the very least it should
> > have accepted a range of errors for those tests, I think--but anyone
> > else that ran pynfs against their server may have assumed it pynfs was
> > correct in these cases....
> 
> Pynfs is not an authoritative source for anything.

We should say that, for what it's worth.  (Below.)

But it's just another reason why servers may have been written to return
something other than err_symlink....  I have in the past had to tell
developers of more than one server that fixing error returns to make
pynfs happy may not be a good idea.

--b.

diff --git a/README b/README
index 0c34b2a..ecb2aa6 100644
--- a/README
+++ b/README
@@ -12,3 +12,9 @@ in place.
 For more details about 4.0 and 4.1 testing, see nfs4.0/README and
 nfs4.1/README, respectively.  For information about automatic code
 generation from an XDR file, see xdr/README.
+
+Note that test results should *not* be considered authoritative
+statements about the protocol--if you find that a server fails a test,
+you should consult the rfc's and think carefully before assuming that
+the server is at fault.  (However, we do appreciate patches if you
+find a test that requires incorrect behavior.)
