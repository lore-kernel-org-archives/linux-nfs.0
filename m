From: Andrew Morton <akpm@osdl.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc
 which isn't checked...
Date: Sat, 7 Feb 2004 21:46:37 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040207214637.387d3018.akpm@osdl.org>
References: <20040206161050.27799.patches@notabene>
	<E1AoyIo-0007FS-00@notabene>
	<20040207012423.396efe73.akpm@osdl.org>
	<20040208043723.GC13391@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aphk0-0005OL-50
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 21:44:24 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aphjz-0006mw-GB
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 21:44:23 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040208043723.GC13391@fieldses.org>
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

"J. Bruce Fields" <bfields@fieldses.org> wrote:
>
> On Sat, Feb 07, 2004 at 01:24:23AM -0800, Andrew Morton wrote:
> > NeilBrown <neilb@cse.unsw.edu.au> wrote:
> > >
> > > There is no way to return an error from a cache init routine,
> > >  so instead we make sure to pre-allocate the memory needed,
> > >  and free it after the lookup if the lookup failed.
> > 
> > This patch causes an oops when the initscripts run exportfs.
> 
> Ugh.  The patches were submitted out of order; #3 should have come
> before #2.
> 

OK.

But with all five patches applied (or the first three) there remains the
deadlock over that write_lock.



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
