Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab3JASpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 14:45:13 -0400
Date: Tue, 1 Oct 2013 14:45:12 -0400
From: "'Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: pynfs updates
Message-ID: <20131001184512.GN26382@fieldses.org>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
 <20130930221126.GD26382@fieldses.org>
 <003f01cebe38$75436480$5fca2d80$@mindspring.com>
 <20131001142601.GG26382@fieldses.org>
 <009a01cebed2$fcdacb50$f69061f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <009a01cebed2$fcdacb50$f69061f0$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 02:21:01PM -0400, Frank Filz wrote:
> > > > 		- SECNN4: is env.home necessarily unequal to "/"?  Would
> > > > 		  seem better to do the lookup in a subdirectory just to
> > > > 		  be certain.
> > >
> > > Env.home is the directory you specify on the command line, I think the
> > > presumption is that it is a writeable file system. Pynfs creates tmp
> > > and tree directories in home (and maybe some files also?). Guess if /
> > > was writeable, you could specify /, so yea, maybe it should go into tmp.
> > 
> > Sounds good.
> 
> env.home does actually include traversing into tmp, so I will leave this
> test alone.

OK!

--b.
