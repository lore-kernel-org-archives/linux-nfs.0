From: Olaf Kirch <okir@suse.de>
Subject: Re: unlock during lockd recovery
Date: Wed, 24 Nov 2004 09:59:05 +0100
Message-ID: <20041124085905.GC7108@suse.de>
References: <20041123081047.GA6874@suse.de> <OF2DFFDFB5.4B33C70C-ON88256F55.006063CF-88256F55.00616D80@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF2DFFDFB5.4B33C70C-ON88256F55.006063CF-88256F55.00616D80@us.ibm.com>
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

On Tue, Nov 23, 2004 at 09:44:10AM -0800, Marc Eshel wrote:
> If the client application unlocks the lock before it was reclaimed than it
> should not be reclaimed.

The problem is that your lockd server would make assumptions about the
client's implementation; in particular, this would mandate that the client
prevents any regular NLM activity while it's in the middle of a reclaim.

However, the X/Open spec for NLM says about NLM_LOCK: "During the grace
period, the server will only accept locks with reclaim set to true."
So the client is free to assume that it's okay to keep on retransmitting
LOCK/UNLOCK request all along, without having to care about reclaim or not,
because the spec says the server will ignore them anyway.

Consider this scenario:

 -	Server tells client to start reclaim
 -	Client sends reclaim request for lock X
 -	RPC packet gets lost
 -	Application requests to unlock X
 -	Client calls server, server finds there's nothing to
 	unlock, ACKs the RPC call
 -	Client retransmits reclaim packet, server re-installs
 	the lock
 -	you have a stale lock

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
