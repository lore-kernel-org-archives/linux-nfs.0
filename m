From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: slowness due to splitting into pages
	in?nfs3svc_decode_writeargs()
Date: Fri, 31 Aug 2007 23:55:29 +0200
Message-ID: <200708312355.30219.bernd-schubert@gmx.de>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<200708312334.50001.bernd-schubert@gmx.de>
	<20070831214306.GO11165@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Brian J. Murrell" <brian@interlinx.bc.ca>,
	nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRESn-0006DB-3Q
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:55:37 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IRESr-0004rD-7i
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:55:41 -0700
In-Reply-To: <20070831214306.GO11165@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday 31 August 2007, J. Bruce Fields wrote:
> On Fri, Aug 31, 2007 at 11:34:49PM +0200, Bernd Schubert wrote:
> > On Friday 31 August 2007, J. Bruce Fields wrote:
> > > There's no guarantee the later pages in the rq_pages array are
> > > contiguous in memory after the first one, so the rest of that iovec
> > > probably has random data in it.
> >
> > Hmm, its some time since I last read rfc1813, but I can't remember
> > something like 'data are send in pages and pages may have random order'.
> > So I guess some kind of multi-threading is filling in the data the client
> > is sending?
>
> The data all arrives in one big chunk, in order.  But then we have to
> put it some place.  The kernel almost never tries to allocate more than
> one contiguous page of memory--memory fragmentation can make it
> difficult to do that reliably--so we just ask for a bunch of pages to
> put the data in, which may represent memory from all over the place,
> store those pages into an array, and receive the data into those pages
> in the order they're listed in the array.

Ah, now I understand, thanks! I'm still used to userspace programming (*)


Thanks,
Bernd


PS: (*) Don't know if I ever will really like kernel programming - it 
remembers me to metal-organic chemistry, everything is a 100 times more 
difficult than usually, even simple weighing 100g of a substance might take a 
few hours.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
