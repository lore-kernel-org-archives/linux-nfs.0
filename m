From: Calum Mackay <calum.mackay@sun.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Wed, 01 Dec 2004 17:17:46 +0000
Message-ID: <41ADFCBA.6040605@sun.com>
References: <OF7203D852.9E05A09B-ON88256F5C.005C4DD8-88256F5C.005DB624@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: "William A.(Andy) Adamson" <andros@citi.umich.edu>,
        Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
        nfs-admin@lists.sourceforge.net,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF7203D852.9E05A09B-ON88256F5C.005C4DD8-88256F5C.005DB624@us.ibm.com>
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

Hi Marc, Andy,

Forgive my late joining of this thread, and apologies if I'm missing 
anything...

How do you intend to handle the stable storage issue? It seems to me 
that to comply with the RFC's requirement that stable storage be used 
when a grace period is offered, there needs to be a Cluster-wide, 
always-consistent, stable-storage, available to all nodes. I imagine 
that a correct implementation of this isn't a trivial exercise... :)

best regards,
calum.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
