Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46235 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751361Ab1HHSHD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 14:07:03 -0400
Date: Mon, 8 Aug 2011 19:06:58 +0100
From: Ben Hutchings <ben@decadent.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Message-ID: <20110808180658.GC29924@decadent.org.uk>
References: <1312810169.2591.1153.camel@deadeye>
 <20110808155538.GB904@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110808155538.GB904@fieldses.org>
Subject: Re: [PATCH] headers, nfsd: Add missing #includes to
 <linux/nfsd/syscall.h>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 08, 2011 at 11:55:38AM -0400, J. Bruce Fields wrote:
> On Mon, Aug 08, 2011 at 02:29:29PM +0100, Ben Hutchings wrote:
> > <linux/nfsd/syscall.h> uses the NFS_MAXPATHLEN and NFS_FHSIZE macros
> > defined in <linux/nfs.h>, and struct knfsd_fh defined in
> > <linux/nfsd/nfsfh.h>.
> 
> Well, the real bug is that this file exists at all.

OK.  I've been more-or-less mechanically fixing headers and I don't
have any particular expectations of this one.

> Neil sent this
> http://marc.info/?l=linux-nfs&m=130881392416899&w=2 in a while ago but I
> didn't want to attempt to merge something that touched every arch
> directory.  I wonder what we should do....
[...]

So long as it's cc'd to linux-arch and linux-kernel, I don't think
that's going to be a problem.  Yes it might conflict, but Linus
(and sfr) can cope with such conflicts.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
