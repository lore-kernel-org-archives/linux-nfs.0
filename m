From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Mon, 6 Dec 2004 10:20:42 -0800
Message-ID: <OFA9F2AC6C.3BEF26DB-ON88256F62.0061B29A-88256F62.0064C5D6@us.ibm.com>
References: <20041206150428.GC20864@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbNa2-0003ub-EQ
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 10:27:26 -0800
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CbNa1-0005q2-7f
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 10:27:26 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iB6IRIBX026281
	for <nfs@lists.sourceforge.net>; Mon, 6 Dec 2004 13:27:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB6IRInO135972
	for <nfs@lists.sourceforge.net>; Mon, 6 Dec 2004 13:27:18 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iB6IRIOY021320
	for <nfs@lists.sourceforge.net>; Mon, 6 Dec 2004 13:27:18 -0500
In-Reply-To: <20041206150428.GC20864@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
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

The "echo 0" was put in mainly for debugging and it is not critical at this
point. In a cluster environment the grace period might need to be set
higher than the minimum value so it is possible to go out of grace period
only when the last machine completed it required minimum grace period. It
might also be possible to fail one client from one machine to another for
load balancing in which case the cluster file system has the locks state
and can determine when all the locks got reclaimed. In this case the
reclaim is done to update the new machine local sate locks (posix locks).

Marc.

"J. Bruce Fields" <bfields@fieldses.org> wrote on 12/06/2004 07:04:28 AM:

> On Tue, Nov 23, 2004 at 07:38:34PM -0800, Marc Eshel wrote:
> > 'echo 1 > /proc/sys/fs/nfs/nlm_grace' will put lockd in grace period
and
> > 'echo 0 > /proc/sys/fs/nfs/nlm_grace' will take it out of grace period
but
> > it is not necessary to 'echo 0' since it will just come out of grace
period
> > when the period ends.

> The "echo 0" is a little dangerous, isn't it?  Do we really need the
> ability to end the grace period prematurely?--b.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
