From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Move (mv) hangs with NFSv4
Date: Tue, 15 Mar 2005 17:31:25 -0500
Message-ID: <20050315223125.GE11916@fieldses.org>
References: <1102097931.10878.21.camel@lade.trondhjem.org> <20041207155227.GG31250@fieldses.org> <41B61C89.2060000@drzeus.cx> <20041207211715.GQ31250@fieldses.org> <41B6E933.4090708@drzeus.cx> <41D84216.9060504@drzeus.cx> <20050312185119.GA1064@fieldses.org> <42346C15.4080402@drzeus.cx> <20050313164804.GA10992@fieldses.org> <4235B5C4.7060800@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBKZ2-0000sI-Ny
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 14:31:00 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBKZ1-0003WC-7o
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 14:31:00 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>
In-Reply-To: <4235B5C4.7060800@drzeus.cx>
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

On Mon, Mar 14, 2005 at 05:03:16PM +0100, Pierre Ossman wrote:
> I've tried the patch and the problem remains.
> 
> [root@apollo home]# ~/mv ~/freedesktop.org.xml .
> Updating timestamps...done
> Updating ownership...
> 
> (this is my hacked mv which lists each operation as it is performed)

Hm.  Maybe my "mv" doesn't work quite the same as yours, but I'm not
seeing this.  Could I see a raw packet trace?  (tcpdump s0 -wtmp, send
me tmp.pcap).  Are you having any problems with rpc.idmapd dying on the
server?

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
