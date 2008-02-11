From: James Lentini <jlentini@netapp.com>
Subject: [ofa-general] Re: new NFS/RDMA instructions for 2.6.25-rc1
Date: Mon, 11 Feb 2008 15:56:17 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0802111552080.23589@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0802111223040.23589@jlentini-linux.nane.netapp.com>
	<20080211173322.GA4755@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, general@lists.openfabrics.org,
	Thomas Talpey <talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080211173322.GA4755@fieldses.org>
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



On Mon, 11 Feb 2008, J. Bruce Fields wrote:

> On Mon, Feb 11, 2008 at 12:25:14PM -0500, James Lentini wrote:
> > 
> > Linux 2.6.25 will be the first official kernel release to contain the
> > NFS/RDMA server. With the client and server now both available in 
> > 2.6.25-rc1, we've simplified our NFS/RDMA installation instructions.
> > The new instructions are available here:
> >  
> >  http://nfs-rdma.sourceforge.net/Documents/README
> 
> Any reason not to add that to the linux tree, say in
> Documentation/filesystems/nfs-rdma.txt?
> 
> --b.

That sounds like a good idea Bruce. The current document is strictly a 
HOWTO. Should we add sections on the design and implementation?
