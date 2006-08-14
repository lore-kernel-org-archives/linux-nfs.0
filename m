From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Mon, 14 Aug 2006 17:43:13 -0400
Message-ID: <20060814214313.GE20034@fieldses.org>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<20060808154923.GA28855@fieldses.org>
	<1155091055.16378.14.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCkDP-00042U-UW
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 14:43:20 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCkDN-0006P4-7n
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 14:43:20 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1155091055.16378.14.camel@hole.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Aug 09, 2006 at 12:37:36PM +1000, Greg Banks wrote:
> On Wed, 2006-08-09 at 01:49, J. Bruce Fields wrote:
> > It'd be nice if we could avoid ripping out a working user interface that
> > someone might be using....
> 
> I agree, but I don't believe a) it's working or b) anyone could
> be getting any use out of it.

OK.  So the advice at

http://nfs.sourceforge.net/nfs-howto/ar01s05.html#nfsd_daemon_instances

is wrong?

> An earlier version of the patch left the data structures in place
> and just reported them as zeros in the /proc file.  Would that
> be preferrable?

I'm not sure that makes any difference.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
