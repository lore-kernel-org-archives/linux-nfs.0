From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc which isn't checked...
Date: Sat, 7 Feb 2004 23:37:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208043723.GC13391@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApghI-0003nS-8G
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 20:37:32 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ApghH-0000BW-RY
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 20:37:32 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040207012423.396efe73.akpm@osdl.org>
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

On Sat, Feb 07, 2004 at 01:24:23AM -0800, Andrew Morton wrote:
> NeilBrown <neilb@cse.unsw.edu.au> wrote:
> >
> > There is no way to return an error from a cache init routine,
> >  so instead we make sure to pre-allocate the memory needed,
> >  and free it after the lookup if the lookup failed.
> 
> This patch causes an oops when the initscripts run exportfs.

Ugh.  The patches were submitted out of order; #3 should have come
before #2.

> Presumably `name' is null.  Sorry, but I'm disinclined to debug those
> macros in there :(

Can't blame you.

--Bruce Fields


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
