From: Olaf Kirch <okir@suse.de>
Subject: Re: NFSv3 ACL status?
Date: Fri, 13 Aug 2004 10:52:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040813085230.GC12123@suse.de>
References: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Astrand <peter@cendio.se>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvXnn-0002hv-Qw
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 01:52:43 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BvXnn-0000Uw-Bx
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 01:52:43 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com>
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

On Thu, Aug 12, 2004 at 08:00:56AM -0700, Lever, Charles wrote:
> i believe what ag's patch set provides is "POSIX ACL support" which
> means he has added the generic file system interfaces needed to support
> ACLs as they are described in the POSIX standards.  "Solaris ACL
> support" means using the Sun-defined NFS side-band protocol to access
> and modify POSIX ACLs via an NFS client.

No; Andreas' patches implement the Solaris ACL side-band protocol for
NFSv3.  These patches are in the suse kernels; I don't know whether or
not they are in any redhat kernels.

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
