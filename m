From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: NFS and partitioned md
Date: Thu, 20 Jul 2006 11:07:36 +0200
Message-ID: <20060720090736.GB1408@janus>
References: <1151355145.4460.16.camel@archon.smoula-in.net>
	<17568.31894.207153.563590@cse.unsw.edu.au>
	<1151432312.11996.32.camel@reaver.netbox-in.cz>
	<17571.19699.980491.970386@cse.unsw.edu.au>
	<44BD2A29.8060405@dgreaves.com>
	<1153253099.26360.3.camel@archon.smoula-in.net>
	<17598.52873.335796.13969@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>,
	David Greaves <david@dgreaves.com>, linux-kernel@vger.kernel.org,
	Martin Filip <bugtraq@smoula.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3UVW-0003vI-5F
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 02:07:46 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3UVV-00076t-7A
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 02:07:46 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17598.52873.335796.13969@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Jul 20, 2006 at 10:30:01AM +1000, Neil Brown wrote:
> On Tuesday July 18, bugtraq@smoula.net wrote:
> > Hi,
> > 
> > my solution was to use fsid parameter for exports... maybe some other
> > mechanism for selecting fsids could be created instead of fsid = device
> > minor
> 
> Yes.  Better management of fsid is on my wishlist for nfs-utils.
> Unfortunately I haven't had any really clever ideas yet.

I'd like to "virtualize" exports such that it is possible to transplant
disks/partitions from one machine into another without having to bother
with device numbering. One step in that direction is to derive the fsid
from an IP address. The server machine needs an additional IP address
for every export entry. This IP address is determined by deriving
a hostname from the last pathname component of the export entry and
resolving it. E.g. something like:

/etc/exports:
	/exported/path/name	*(rw,sync,no_root_squash,no_subtree_check,fsid="nfs-%s")

This would set the fsid to the IP address of host "nfs-name".

-- 
Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
