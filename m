Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40870 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab3JBLgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 07:36:08 -0400
Date: Wed, 2 Oct 2013 07:36:07 -0400
From: "'Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: pynfs updates
Message-ID: <20131002113607.GA7906@fieldses.org>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
 <20130930221126.GD26382@fieldses.org>
 <003f01cebe38$75436480$5fca2d80$@mindspring.com>
 <20131001142601.GG26382@fieldses.org>
 <20131001143051.GH26382@fieldses.org>
 <00b801cebed9$312b6030$93822090$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00b801cebed9$312b6030$93822090$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 03:05:23PM -0400, Frank Filz wrote:
> > One more problem: CSID10 is failing against the Linux server with
> > NFS4ERR_TOO_MANY_OPS, because each of those lookups is actually a full
> > lookup from PUTROOTFH to /, resulting in 17 ops on my setup.  Could we
> > maybe work relative to the parent directory instead?
> 
> Ok, was able to fix this by doing a LOOKUP sequence in a separate compound
> followed by GETFH then in the compound that tests SAVEFH/RESTOREFH, just do
> PUTFH that saved FH.
> 
> Things could be a lot smoother as discussed on IRC if the initialization
> stored away env.home_fh.
> 
> Then with some work, this test could be simplified to:
> 
> SEQUENCE, PUTFH(env.home_fh), OPEN, GETFH, SAVEFH, PUTFH(env.home_fh),
> RESTOREFH, CLOSE
> 
> Note that that GETFH is not actually used by this test, but presumably
> open_create_op() would produce:
> 
> PUTFH(env.home_fh), OPEN, GETFH
> 
> Instead of what it currently does:
> 
> PUTROOTFH, LOOKUP..., OPEN, GETFH
> 
> The new branch is here:
> 
> https://github.com/ffilz/pynfs/commits/master

Pulled, thanks!

--b.
