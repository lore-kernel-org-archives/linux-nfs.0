From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 8 Aug 2006 11:49:23 -0400
Message-ID: <20060808154923.GA28855@fieldses.org>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GATpg-0002Pz-AP
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 08:49:28 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GATpf-0001iA-KD
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 08:49:28 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1155032558.29877.324.camel@hole.melbourne.sgi.com>
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

On Tue, Aug 08, 2006 at 08:22:44PM +1000, Greg Banks wrote:
> I'm still working on another patch (it only recently became possible
> with the ktime_t code) which replaces threadstats fully.  That patch
> adds nanosecond resolution busy and idle counters to each thread,
> then aggregates them per-pool when you read the pool_stats file.
> After export to userspace and rate conversion, these numbers tell
> us directly what percentage of the nfsds are currently being used.

Would it be possible to use that to continue to support the existing
interface (the "th" line)?

It'd be nice if we could avoid ripping out a working user interface that
someone might be using....

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
