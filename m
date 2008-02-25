From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [ofa-general] Re: new NFS/RDMA instructions for 2.6.25-rc1
Date: Mon, 25 Feb 2008 13:12:39 -0500
Message-ID: <20080225181239.GC12051@fieldses.org>
References: <Pine.LNX.4.64.0802111223040.23589@jlentini-linux.nane.netapp.com> <20080211173322.GA4755@fieldses.org> <Pine.LNX.4.64.0802111552080.23589@jlentini-linux.nane.netapp.com> <20080211210044.GA4561@fieldses.org> <Pine.LNX.4.64.0802251140290.16537@jlentini-linux.nane.netapp.com> <ada7igt2cjf.fsf@cisco.com> <Pine.LNX.4.64.0802251214550.16537@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, linux-nfs@vger.kernel.org,
	general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org, Thomas Talpey <talpey@netapp.com>
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43767 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbYBYSM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2008 13:12:56 -0500
In-Reply-To: <Pine.LNX.4.64.0802251214550.16537-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 25, 2008 at 12:20:13PM -0500, James Lentini wrote:
> 
> 
> On Mon, 25 Feb 2008, Roland Dreier wrote:
> 
> >  > +  - Install an OpenFabrics-compatible RDMA card
> >  > +
> >  > +    Any device that is compatible with the OpenFabrics.org software stack is 
> >  > +    acceptable.
> > 
> > This seems a little odd in the context of instructions on how to use
> > the code in the kernel.  Maybe something like:
> > 
> >  - Install an RDMA device
> > 
> >    Any device supported by the drivers in drivers/infiniband/hw is
> >    acceptable.
> > 
> >  - R.
> 
> I agree. Your wording is clearer.
> 
> Bruce, 
> 
> Here's an update incorporating Roland's suggestion.
> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
> --- /dev/null	2008-01-17 11:34:08.491004516 -0500
> +++ Documentation/nfs-rdma.txt	2008-02-25 12:18:17.937932000 -0500

That actually puts the file in the top-level directory.  I moved it to
./Documentation/filesystems/, and stripped trailing whitespace.
Assuming that's OK, it's queued up for 2.6.26.  Thanks!

--b.
