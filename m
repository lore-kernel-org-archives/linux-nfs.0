From: James Lentini <jlentini@netapp.com>
Subject: Re: [ofa-general] Re: new NFS/RDMA instructions for 2.6.25-rc1
Date: Mon, 25 Feb 2008 13:15:11 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0802251314130.16537@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0802111223040.23589@jlentini-linux.nane.netapp.com>
	<20080211173322.GA4755@fieldses.org>
	<Pine.LNX.4.64.0802111552080.23589@jlentini-linux.nane.netapp.com>
	<20080211210044.GA4561@fieldses.org>
	<Pine.LNX.4.64.0802251140290.16537@jlentini-linux.nane.netapp.com>
	<ada7igt2cjf.fsf@cisco.com>
	<Pine.LNX.4.64.0802251214550.16537@jlentini-linux.nane.netapp.com>
	<20080225181239.GC12051@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <rdreier@cisco.com>, linux-nfs@vger.kernel.org,
	general@lists.openfabrics.org, Thomas Talpey <talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080225181239.GC12051@fieldses.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-ID: <linux-nfs.vger.kernel.org>



On Mon, 25 Feb 2008, J. Bruce Fields wrote:

> On Mon, Feb 25, 2008 at 12:20:13PM -0500, James Lentini wrote:
> > 
> > 
> > On Mon, 25 Feb 2008, Roland Dreier wrote:
> > 
> > >  > +  - Install an OpenFabrics-compatible RDMA card
> > >  > +
> > >  > +    Any device that is compatible with the OpenFabrics.org software stack is 
> > >  > +    acceptable.
> > > 
> > > This seems a little odd in the context of instructions on how to use
> > > the code in the kernel.  Maybe something like:
> > > 
> > >  - Install an RDMA device
> > > 
> > >    Any device supported by the drivers in drivers/infiniband/hw is
> > >    acceptable.
> > > 
> > >  - R.
> > 
> > I agree. Your wording is clearer.
> > 
> > Bruce, 
> > 
> > Here's an update incorporating Roland's suggestion.
> > 
> > Signed-off-by: James Lentini <jlentini@netapp.com>
> > 
> > --- /dev/null	2008-01-17 11:34:08.491004516 -0500
> > +++ Documentation/nfs-rdma.txt	2008-02-25 12:18:17.937932000 -0500
> 
> That actually puts the file in the top-level directory.  I moved it to
> ./Documentation/filesystems/, and stripped trailing whitespace.
> Assuming that's OK, 

Sounds good. 

> it's queued up for 2.6.26.  Thanks!

Great.

> --b.
> 
