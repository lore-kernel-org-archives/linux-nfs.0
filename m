From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: NFS3PROC_ACCESS bug in 2.6.x
Date: Tue, 15 Feb 2005 21:23:40 +0100
Message-ID: <20050215202340.GA18603@janus>
References: <20050206183913.GA28176@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D19Ee-0008J9-7B
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 12:23:52 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D19Ec-0007h8-Lv
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 12:23:52 -0800
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <20050206183913.GA28176@janus>
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

On Sun, Feb 06, 2005 at 07:39:13PM +0100, Frank van Maarseveen wrote:
> 
> [blurb]

must have been a "ro" export (automatically appearently, unless "rw"
specified). user error (*blush*).

-- 
Frank


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
