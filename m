From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Tue, 30 Nov 2004 09:03:34 -0800
Message-ID: <OF7203D852.9E05A09B-ON88256F5C.005C4DD8-88256F5C.005DB624@us.ibm.com>
References: <20041130155507.5DBD11BB00@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: andros@citi.umich.edu, Neil Brown <neilb@cse.unsw.edu.au>,
        nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <20041130155507.5DBD11BB00@citi.umich.edu>
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
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



William A.(Andy) Adamson wrote on 11/30/2004 07:55:07 AM:

> The NFSv4 portion looks ok to me; I'm lockd ignorant :-)

> To migrate a client from NFSv4 server1 to NFSv4 server2 both exporting a
> shared file system, the administrator will perform the following tasks

> 1) expire the client on NFSv4 server1 (remove the in-memory client state)
> 2) turn on (toggle) the grace period for all NFSv4 servers exporting the
> shared file system
> 3) change the mount on the client from NFSv4 server1 to NFSv4 server2.

I would do step 2 first to make sure that the client doesn't lose any locks
in the window between step 1 and 2.
I hope that when we are done the administrator will not have to do anything
on the client machines but instead the fs-location/moved will be used to
redirect the client from one server to another.

> While in the grace period, all NFSv4 servers will deny all non-recalim
OPEN
> and LOCK requests. READ/WRITE/SETATTR(file size change) on existing or
> reclaimed OPEN/LOCK will succeed. So, when an NFSv4 client migrates from
one
> NFSv4 server to another NFSv4 server (both exporting a shared file
system),
> *all* non-reclaim OPEN/LOCK request from any client will stall with
> NFS4_ERR_GRACE.

> I just completed a patch to allow READ/WRITE/SETATTR(file size change)
while
> in the grace period for existing/reclaimed state.

> I'm currently working on the stable storage portion of the NFSv4 server
> reclaim.

> -->Andy

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
