From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Wed, 14 Jul 2004 19:24:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040714232437.GB12551@fieldses.org>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040713180108.GF3023@fieldses.org> <20040713210950.GB22659@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bkt7A-0001W5-40
	for nfs@lists.sourceforge.net; Wed, 14 Jul 2004 16:24:40 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bkt79-0002GZ-MF
	for nfs@lists.sourceforge.net; Wed, 14 Jul 2004 16:24:40 -0700
Received: from bfields by pickle.fieldses.org with local (Exim 4.34)
	id 1Bkt77-0003Kb-Ur
	for nfs@lists.sourceforge.net; Wed, 14 Jul 2004 19:24:37 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <20040713210950.GB22659@polop.usc.edu>
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

On Tue, Jul 13, 2004 at 02:09:50PM -0700, Garrick Staples wrote:
> It's about choice, isn't it?  Some sites may want to maintain the same
> numbers over time, other sites might want to zero them.

What choice?  You can do everything you need with the current kernel
interface.

> If someone zeros the numbers and messes up something else, that's the admin's
> perogative to break things.

Maybe, but this gives the administrator one more way to break things
without giving them any real new functionality.  On balance that seems a
poor tradeoff.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
