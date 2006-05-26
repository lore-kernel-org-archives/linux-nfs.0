From: Neil Brown <neilb@suse.de>
Subject: Re: 2.4 vs 2.6
Date: Fri, 26 May 2006 17:30:56 +1000
Message-ID: <17526.44720.169339.729336@cse.unsw.edu.au>
References: <a9ed420f0605250035i31a8925cv454d3ca15d7cab91@mail.gmail.com>
	<17526.44653.228663.713864@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FjWml-00034t-IW
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 00:31:03 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FjWml-0008VV-9x
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 00:31:03 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FjWmk-0000DE-TA
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 00:31:03 -0700
To: "Vijay Chauhan" <kernel.vijay@gmail.com>,
	nfs@lists.sourceforge.net
In-Reply-To: message from Neil Brown on Friday May 26
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday May 26, neilb@suse.de wrote:
> On Thursday May 25, kernel.vijay@gmail.com wrote:
> > Hi,
> > Can anyone tell me what are the differences in the linux kernel 2.4 version
> > and 2.6 version related to NFS implementation
> 
> How much detail do you want?
> 
> Apart from adding NFSv4, the main difference is the authentication
> cache with support for up-calls.
> In 2.4, exportfs and mountd had to tell the kernel about any export
> information that it might need to know.
> In 2.6, the kernel can ask mountd, and mountd will provide information
> on-demand.
> 
> NeilBrown

Ofcourse, that is just the server.  There have been lots of changes to
the client as well including RPCSEC support and much much more.

What exactly do you need to know?

NeilBrown


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
