From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Move (mv) hangs with NFSv4
Date: Tue, 7 Dec 2004 16:17:15 -0500
Message-ID: <20041207211715.GQ31250@fieldses.org>
References: <41B0A79A.2010203@drzeus.cx> <1102097931.10878.21.camel@lade.trondhjem.org> <20041207155227.GG31250@fieldses.org> <41B61C89.2060000@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cbmhq-0000tR-NH
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 13:17:10 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cbmhp-0008Dw-GM
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 13:17:10 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>
In-Reply-To: <41B61C89.2060000@drzeus.cx>
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

On Tue, Dec 07, 2004 at 10:11:37PM +0100, Pierre Ossman wrote:
> Here's a tcpdump of the transfer (I figure that's what you mean with a 
> pcap file). The last couple of packets keep repeating themselves so the 
> line never goes quiet (until I ^C).
> The transfer is a mv of a empty file named 'foo'.

Thanks.  It's a problem with the idmapping on the server, argh.  Is
rpc.idmapd still running after this, or does it die?--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
