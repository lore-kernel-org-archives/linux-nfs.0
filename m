From: Andrew Morton <akpm@osdl.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc
 which isn't checked...
Date: Mon, 9 Feb 2004 14:10:56 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209141056.33903207.akpm@osdl.org>
References: <20040206161050.27799.patches@notabene>
	<E1AoyIo-0007FS-00@notabene>
	<20040207012423.396efe73.akpm@osdl.org>
	<20040208043723.GC13391@fieldses.org>
	<20040207214637.387d3018.akpm@osdl.org>
	<20040208055921.GA14053@fieldses.org>
	<20040208203018.GA27482@fieldses.org>
	<20040209093206.429ffb7e.akpm@osdl.org>
	<20040209215151.GE2776@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	philippe.gramoulle@mmania.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqLcw-0006HP-OE
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:19:46 -0800
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqJau-0002ll-Uk
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 14:09:32 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqJas-0007gO-Fi
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 14:09:30 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040209215151.GE2776@fieldses.org>
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
> The version of nfsd-03-sunrpc-cache-init-fixes.patch in 2.6.3-rc1-mm1
> isn't the one I sent; note that the only change I made was to add a few
> lines to net/sunrpc/svcauth.c (a file that that patch didn't modify
> before), and that chunk isn't in there.

You're right, I screwed up, didn't notice that svcauth.c was added.

If poss, incremental patches are always preferred to wholesale replacement,
please.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
