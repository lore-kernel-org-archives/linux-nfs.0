From: Olaf Kirch <okir@suse.de>
Subject: Re: #255931 NFS fh_verify causes lost output
Date: Fri, 20 Aug 2004 11:44:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040820094438.GB23176@suse.de>
References: <20040818210041.A2223@infradead.org> <16677.25168.374531.344188@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Paul Szabo <psz@maths.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By5yj-00021K-O2
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 02:46:33 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1By5yi-0004IW-8m
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 02:46:33 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16677.25168.374531.344188@cse.unsw.edu.au>
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

Hi Neil,

> Originally, the check here was "does anyone other that root have x
> permission" and "it is exported root_squash".
> If the first was "no" and the second was "yes", then access was
> denied.

But that is an access control check; and a failed access control
check should return EACCES.

Probably the worst aspect of returning ESTALE is that this information
is cached persistently by the client; it doesn't time out. So it will
never clear up, even if the directory is changed to mode 777 in the
meanwhile.

>  2/ change the error to EPERM, which is wrong because filehandle
>     lookup itself shouldn't return EPERM, and if the failure is

Then we shouldn't mix permission checks with file handle lookup.
As far as I understand, the only reason this permission check is
done inside the file handle lookup is because a file handle may
potentially map to more than on dentry chain?

For what it's worth, I can live with both solution 1 and solution 2.
I don't believe in 4.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
