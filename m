From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Fri, 3 Dec 2004 10:32:17 -0800
Message-ID: <OF5D50C851.638664CE-ON88256F5F.0064A7E2-88256F5F.0065D563@us.ibm.com>
References: <16815.63554.437489.308079@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <16815.63554.437489.308079@cse.unsw.edu.au>
To: Neil Brown <neilb@cse.unsw.edu.au>
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

I was hopping that the following two (small but important for HA) changes
be included.

1. statd doesn't exit when called in notify mode (-N)
      http://marc.theaimsgroup.com/?l=linux-nfs&m=110062624418905&w=2

2. send the notify message on the same interface as the address in the -n
option
      http://marc.theaimsgroup.com/?l=linux-nfs&m=110064006512730&w=2

Thanks, Marc.

nfs-admin@lists.sourceforge.net wrote on 12/02/2004 09:23:14 PM:

> I have made available a pre-release of nfs-utils 1.0.7.

> It can be downloaded from
> http://sourceforge.net/project/showfiles.php?group_id=14
> or
> http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
>
> The reason for the pre-release is that there are a number of changes that
> I haven't had a chance to test properly, and some that I am not in a
position
> to test.

> There are an assortment of bug-fixes, some support for fail-over
clustering,
> and support for 'gss' authentication.

> I would appreciate it if people could check that it compiles and
> works for them,
> and let me know the success rate.

> I hope to put this out as a final 1.0.7 before Christmas.  Having
> lots of people
> say "Yes, I've tried it, and it works OK" would make a great
> Christmas present :-)

> NeilBrown 03-December-2004

>
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
