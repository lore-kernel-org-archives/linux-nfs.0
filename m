Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699Ab3AUUAF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2013 15:00:05 -0500
Date: Mon, 21 Jan 2013 15:00:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: richard@vdtoorn.nl
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hanging nfs4+krb5 mounts with negative uids?
Message-ID: <20130121200000.GA1820@fieldses.org>
References: <26b3643c253ee306d593bb4b20ff095b.squirrel@vdtoorn.nl>
 <20130121161123.GB16357@fieldses.org>
 <c7d3923f1438a9217cfbb53744b5be21.squirrel@vdtoorn.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <c7d3923f1438a9217cfbb53744b5be21.squirrel@vdtoorn.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2013 at 08:38:16PM +0100, richard@vdtoorn.nl wrote:
> Hi Bruce,
> 
> Well done! Your answer to upgrade to a later version of the kernel fixed
> the problem. I tested this on kernel 3.7.3 and it works beautifully.

Thanks for confirming.--b.

> 
> Thanks very much!
> 
> Richard
> 
> >> This code gets hit, e.g. with the new debian stable release where
> >> nfs-kernel-server/nfs-common is upgraded to 1.2.6-3 (or upgrade
> >> nfs-kernel-server from debian stable to debian unstable). On my
> >> nfsv4+krb5
> >> system, this seems to do exactly the opposite of the patch: not fixing,
> >> but in fact introducing a hanging mount.
> >>
> >> When I change the code back from unsigned uid's to signed uid's the
> >> mount
> >> works again.
> >
> > Assuming you're running kernel 3.7--this shoulds like the problem fixed
> > by kernel commit 621eb19ce1ec.. "svcrpc: Revert "sunrpc/cache.h: replace
> > simple_strtoul"", which has also been backported to 3.7.3.  Could you
> > let us know whether applying that patch, or upgrading to 3.7.3, fixes
> > the problem?
> >
> > --b.
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
