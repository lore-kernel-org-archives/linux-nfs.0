From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Mon, 6 Dec 2004 12:05:20 +1100
Message-ID: <16819.45136.432467.242891@cse.unsw.edu.au>
References: <16815.63554.437489.308079@cse.unsw.edu.au>
	<OF5D50C851.638664CE-ON88256F5F.0064A7E2-88256F5F.0065D563@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb7Jk-0000AG-4I
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 17:05:32 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cb7Jh-0002eZ-E4
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 17:05:32 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: message from Marc Eshel on Friday December 3
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

On Friday December 3, eshel@almaden.ibm.com wrote:
> I was hopping that the following two (small but important for HA) changes
> be included.
> 
> 1. statd doesn't exit when called in notify mode (-N)
>       http://marc.theaimsgroup.com/?l=linux-nfs&m=110062624418905&w=2
> 
> 2. send the notify message on the same interface as the address in the -n
> option
>       http://marc.theaimsgroup.com/?l=linux-nfs&m=110064006512730&w=2
> 
> Thanks, Marc.

Ok, they are in the CVS now, thanks.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
