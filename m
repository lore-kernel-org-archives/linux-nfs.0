From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Tue, 30 Nov 2004 10:55:07 -0500
Message-ID: <20041130155507.5DBD11BB00@citi.umich.edu>
References: <OF18261FA7.4925FE2B-ON88256F5B.007E3E64-88256F5B.007F730F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	nfs-admin@lists.sourceforge.net, andros@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-reply-to: Your message of "Mon, 29 Nov 2004 15:12:05 PST."
             <OF18261FA7.4925FE2B-ON88256F5B.007E3E64-88256F5B.007F730F@us.ibm.com>
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

Trond Myklebust wrote on 11/24/2004 04:15:22 PM:

> So I'm an advocate of moving towards a common interface for grace period
> management for the reasons I stated in the earlier mails.

> Since the NFSv4 state model is by and large a superset of what lockd
> has, I'd argue that we should move the lockd grace stuff into the NFSv4
> interface rather than the opposite.


eshel@almaden.ibm.com said:
> Here is a new patch where NFSv3/v4 grace period can be controlled (on/
> off). The option was added to NFSv4 which than controls lockd grace
> period. V4 and lockd are now synchronized as to when they go into
> grace period and they use the same period which is v4's grace period.

The NFSv4 portion looks ok to me; I'm lockd ignorant :-)

To migrate a client from NFSv4 server1 to NFSv4 server2 both exporting a 
shared file system, the administrator will perform the following tasks

1) expire the client on NFSv4 server1 (remove the in-memory client state)
2) turn on (toggle) the grace period for all NFSv4 servers exporting the 
shared file system
3) change the mount on the client from NFSv4 server1 to NFSv4 server2.

While in the grace period, all NFSv4 servers will deny all non-recalim OPEN 
and LOCK requests. READ/WRITE/SETATTR(file size change) on existing or 
reclaimed OPEN/LOCK will succeed. So, when an NFSv4 client migrates from one 
NFSv4 server to another NFSv4 server (both exporting a shared file system), 
*all* non-reclaim OPEN/LOCK request from any client will stall with 
NFS4_ERR_GRACE.

I just completed a patch to allow READ/WRITE/SETATTR(file size change) while 
in the grace period for existing/reclaimed state.

I'm currently working on the stable storage portion of the NFSv4 server 
reclaim.

-->Andy






-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
