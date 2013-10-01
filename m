Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:49379 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751875Ab3JATFe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 15:05:34 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Bruce Fields'" <bfields@fieldses.org>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com> <20130930221126.GD26382@fieldses.org> <003f01cebe38$75436480$5fca2d80$@mindspring.com> <20131001142601.GG26382@fieldses.org> <20131001143051.GH26382@fieldses.org>
In-Reply-To: <20131001143051.GH26382@fieldses.org>
Subject: RE: pynfs updates
Date: Tue, 1 Oct 2013 15:05:23 -0400
Message-ID: <00b801cebed9$312b6030$93822090$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> One more problem: CSID10 is failing against the Linux server with
> NFS4ERR_TOO_MANY_OPS, because each of those lookups is actually a full
> lookup from PUTROOTFH to /, resulting in 17 ops on my setup.  Could we
> maybe work relative to the parent directory instead?

Ok, was able to fix this by doing a LOOKUP sequence in a separate compound
followed by GETFH then in the compound that tests SAVEFH/RESTOREFH, just do
PUTFH that saved FH.

Things could be a lot smoother as discussed on IRC if the initialization
stored away env.home_fh.

Then with some work, this test could be simplified to:

SEQUENCE, PUTFH(env.home_fh), OPEN, GETFH, SAVEFH, PUTFH(env.home_fh),
RESTOREFH, CLOSE

Note that that GETFH is not actually used by this test, but presumably
open_create_op() would produce:

PUTFH(env.home_fh), OPEN, GETFH

Instead of what it currently does:

PUTROOTFH, LOOKUP..., OPEN, GETFH

The new branch is here:

https://github.com/ffilz/pynfs/commits/master

Frank


