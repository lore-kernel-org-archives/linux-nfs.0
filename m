Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755410Ab2KMW4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 17:56:13 -0500
Date: Tue, 13 Nov 2012 17:56:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank S Filz <ffilz@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Fw: pynfs updates
Message-ID: <20121113225607.GB11545@fieldses.org>
References: <OFA49718FA.4B5DDB35-ON87257AB5.007B0805-88257AB5.007B136E@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OFA49718FA.4B5DDB35-ON87257AB5.007B0805-88257AB5.007B136E@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, thanks--applied to git://linux-nfs.org/~bfields/pynfs.git master.

--b.

On Tue, Nov 13, 2012 at 02:24:19PM -0800, Frank S Filz wrote:
> 
> 
> I pushed a series of pynfs patches based on Bruce Field's pynfs branch to
> Github:
> 
> git@github.com:ffilz/pynfs.git
> https://github.com/ffilz/pynfs/commits/master
> 
> 05cf3bc49673e61f01a06600569d99d637f98917 Added LOOKP6 to test Xdev by
> lookup into homedir and back to root
> 1f4d4fece0bb86de0f2d2479c94854e62c7ad919 Do LINK2 in home directory
> b85a2387d914798947c755b72cfc5198685654bb Implement RD9g, WRT10g, and
> LOCK11g to test Ganesha bad stateid
> bd458601b6fb4661828dcc2bec8cd7c57c240d2a Add Ganesha specific
> makeBadIDganesha
> 3e57fbde53e248168ee48a78553fe34ec0054053 Remove RD9 and WRT10 as generic
> tests
> 
> I removed RD9 and WRT10 since these tests rely on makeBadID which attempts
> to corrupt a stateid to evoke NFS4ERR_BAD_STATEID, but doesn't seem to work
> even on RHEL 6.2 knfsd. I added makeBadIDganesha to corrupt the stateid in
> a way that causes Ganesha to return NFS4ERR_BAD_STATEID and then used that
> in new tests RD9g and WRT10g. LOCK11 causes the server to respond with
> NFS4ERR_BAD_STATEID by using the all-zero stateid, however, it's worth
> testing with a corrupted stateid also, so I added LOCK11g that uses
> makeBadIDganesha to do so.
> 
> LINK2 was testing the server response to no SavedFH by doing PUTROOTFH,
> LINK. Ganesha does all the checking on CurrentFH including export
> permissions before checking SavedFH, and so was returning NFS4ERR_ROFS
> because pseudo root is read-only. I modified LINK2 to LOOKUP into the
> homedir and then do LINK without SAVEFH so that the test will not depend on
> CurrentFH checking in pseudo root.
> 
> I added a new LOOKP6 test that tests LOOKUPP crossing back over a junction
> by LOOKUP into homedir and then LOOKUPP back to pseudo root. Assuming there
> is a junction between pseudo root and homedir, this will test LOOKUPP back
> across a junction without needing any special server setup.
> 
> I hope these patches are useful.
> 
> With these patches, I have ganesha getting these results after running: all
> ganesha noCLOSE4 noLOCK8c noLOCK18 noLOCK19 noLOCK21 noLOCK22 noLOCKHELD
> LOOKP6
> 
> Command line asked for 579 of 652 tests
> Of those: 8 Skipped, 11 Failed, 2 Warned, 558 Passed
> 
> Frank
