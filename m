From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Wed, 01 Dec 2004 15:58:47 -0500
Message-ID: <20041201205847.58D211BB60@citi.umich.edu>
References: <41ADFCBA.6040605@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Eshel <eshel@almaden.ibm.com>,
	"William A.(Andy) Adamson" <andros@citi.umich.edu>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	nfs-admin@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>, andros@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
To: Calum Mackay <calum.mackay@sun.com>
In-reply-to: Your message of "Wed, 01 Dec 2004 17:17:46 GMT."
             <41ADFCBA.6040605@sun.com>
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

> Hi Marc, Andy,
> 
> Forgive my late joining of this thread, and apologies if I'm missing 
> anything...
> 
> How do you intend to handle the stable storage issue? It seems to me 
> that to comply with the RFC's requirement that stable storage be used 
> when a grace period is offered, there needs to be a Cluster-wide, 
> always-consistent, stable-storage, available to all nodes. I imagine 
> that a correct implementation of this isn't a trivial exercise... :)
> 
> best regards,
> calum.

i plan to use the cluster wide file system.

-->Andy

> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
