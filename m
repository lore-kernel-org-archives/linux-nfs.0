From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Thu, 17 Feb 2005 11:00:30 -0500
Message-ID: <20050217160029.GC26738@fieldses.org>
References: <41E816B3.4030702@mitre.org> <1105747170.28849.22.camel@lade.trondhjem.org> <41F13749.4090900@int-evry.fr> <1106329537.9849.68.camel@lade.trondhjem.org> <41FB6A10.6000001@int-evry.fr> <006701c50627$81122b70$06000800@americas.hpqcorp.net> <41FCC5FF.6030703@int-evry.fr> <4214A200.3040206@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iozone <capps@iozone.org>, Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Blaine <jblaine@mitre.org>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1o52-0004aE-IR
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 08:00:40 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1o51-00013s-3A
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 08:00:40 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: <4214A200.3040206@int-evry.fr>
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

On Thu, Feb 17, 2005 at 02:54:08PM +0100, jehan.procaccia wrote:
> Hello, I didn't received  any answer to the post below ...  anyway  ,  I 
> finally published my iozone/bonnie++/tar bench here:
> http://www.int-evry.fr/s2ia/user/procacci/Doc/NFS/nfs.html#htoc48
> 
> unfortunatly most of them are saturated by the 12.5MB (100Mb)  ethernet 
> bottle neck, and for the iozone cache suppression I couldn't find a way 
> to run corretly with the -U option (which mount/umount FS at every 
> tests) because of this error on the nfs server:
> rpc.mountd: refused mount request from arvouin.int-evry.fr for /p2v5f3 
> (/p2v5f3): illegal port 34111
> 
> I must admit  that in the logs I occationnaly get this "illegal port" 
> error , even for regular NFS clients (not only iozone testers !) .
> Is this a bug ? a mis configuration ?

It sounds like you just need to add the "insecure" export option to the
relevant export in /etc/exports.  See "man exports".

--Bruce Fields


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
