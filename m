From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre2
Date: Fri, 17 Dec 2004 15:00:57 +1100
Message-ID: <16834.23033.457317.370416@cse.unsw.edu.au>
References: <16825.223.924965.582375@cse.unsw.edu.au>
	<200412101420.06172.bernd-schubert@web.de>
	<20041210143032.GB5886@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernd Schubert <bernd-schubert@web.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cf9Ik-0008E5-LE
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:01:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cf9Ik-0002LU-0Z
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 20:01:10 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Friday December 10
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

On Friday December 10, bfields@fieldses.org wrote:
> On Fri, Dec 10, 2004 at 02:20:06PM +0100, Bernd Schubert wrote:
> > Should the configure script assume '--disable-gss' when --disable-nfsv4 is 
> > given? 
> 
> It's possible someone could want gss but not nfsv4; the two are
> independent, since gss works for all nfs versions.

s/are/should be/

The point is that svcgssd_proc.c includes nfsidmap.h, so gss support
won't build without nfsidmap.h even thought it shouldn't be needed.
Maybe this can be cleaned up for 1.0.8, but I'll release 1.0.7 with an
extra check for nfsidmap.h is gss is selected.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
