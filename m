From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re:
	=?iso-8859-1?q?slowness_due_to_splitting_into_pages_in=09nf?=
	=?iso-8859-1?q?s3svc=5Fdecode=5Fwriteargs_=28=29?=
Date: Sat, 1 Sep 2007 01:34:03 +0200
Message-ID: <200709010134.03876.bernd-schubert@gmx.de>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<1188586335.26165.104.camel@pc.ilinx>
	<20070831190001.GD11165@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Brian J. Murrell" <brian@interlinx.bc.ca>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRG0D-00072J-16
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 16:34:13 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IRG0G-0004IS-2J
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 16:34:17 -0700
In-Reply-To: <20070831190001.GD11165@fieldses.org>
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
> On Fri, Aug 31, 2007 at 02:52:15PM -0400, Brian J. Murrell wrote:
> > On Fri, 2007-08-31 at 14:45 -0400, J. Bruce Fields wrote:
> > > Hm.  Any chance this is the same problem?:
> > >
> > > 	http://marc.info/?l=linux-nfs&m=112289652218095&w=2
> >
> > Did this ever land anywhere?
>
> No--I think there were some discussion of problems in the followup
> posts.

To sum up this discussion:

There are two choices to move the data:

1.) To page 2 ... n - this will overwrite nfsv4 at the end of page n.

2.) To page 1 ... n - 1 - this will overwrite the header, thus, all pointers 
to that memory will point to wrong data now.

Seems both aproaches are troublesome and nobody bothered to implement it. Not 
that I much like the idea of data moving at all, but what about

3.) On allocating the pages, allocate one page more than required. After 
filling in page 1, skip page 2 and proceed with page 3.
Now we would have space to properly move the data later on, thus:

memcpy  (page2, page1 + hdr, PAGE_SIZE - hdr_length)
memcpy  (page2 + PAGE_SIZE - hdr_length, page3, hdr_length)

memmove(page3, page3 + hdr_length, PAGE_SIZE - hdr_length)
[...] 


Can you point me to the function assigning the data-block from the network to 
the page-vector?

Thanks,
Bernd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
