From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Tue, 7 Dec 2004 10:27:57 -0500
Message-ID: <20041207152757.GE31250@fieldses.org>
References: <16815.63554.437489.308079@cse.unsw.edu.au> <OF5EAC57B5.E871608D-ON08256F5F.00634442-08256F5F.00638979@us.ibm.com> <16819.42233.176348.675235@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bruce Allan <bruce.allan@us.ibm.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbhFy-0007fL-NX
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 07:28:02 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CbhFx-0000Dq-E5
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 07:28:02 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16819.42233.176348.675235@cse.unsw.edu.au>
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

On Mon, Dec 06, 2004 at 11:16:57AM +1100, Neil Brown wrote:
> Yes........
> 
> It works better with 
>     ./configure --disable-gss --disable-nfsv4
> 
> Bruce Fields would really rather distros compiled it with nfsv4
> support enabled and so it made that the default.  However that
> requires an extra package (or two?) which aren't commonly installed.
> 
> Bruce should be back from leave in a day or two so I might leave him
> to argue further for keeping --enable-nfsv4 as the default (or to cave
> it and let it be changed :-))

The --enable-nfsv4 option just builds and installs rpc.idmapd, which is
required for nfsv4.

This doesn't mean rpc.idmapd has to be run by default.  But by
installing it, a distribution makes it convenient for users to try nfsv4
if they want.

The dependency on libnfsidmap should be easy to satisfy: you can get
the latest libnfsidmap tarball from

	http://www.citi.umich.edu/projects/nfsv4/linux/

which includes all the infrastructure to build a Debian package.  Or
look at Steve Dickson's latest Fedora nfs-utils rpm's for another
example.  (He just includes libnfsidmap with the Fedora rpm and links it
statically.)

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
