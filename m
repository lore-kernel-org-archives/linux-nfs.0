From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: unlock during lockd recovery
Date: Tue, 23 Nov 2004 09:44:10 -0800
Message-ID: <OF2DFFDFB5.4B33C70C-ON88256F55.006063CF-88256F55.00616D80@us.ibm.com>
References: <20041123081047.GA6874@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <20041123081047.GA6874@suse.de>
To: Olaf Kirch <okir@suse.de>
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



nfs-admin@lists.sourceforge.net wrote on 11/23/2004 12:10:47 AM:

> On Mon, Nov 22, 2004 at 04:45:53PM -0800, Marc Eshel wrote:
> > Is there a reason why unlock needs to wait for the lockd to come out of
> > grace period ?

> The lock may not have been reclaimed by the client yet, so you may end up
> with a stale lock.


If the client application unlocks the lock before it was reclaimed than it
should not be reclaimed.
Isn't there some serialization of activity on the client between the client
requests for lock/unlock and the reclaim process?

Marc.


> Olaf
> --
> Olaf Kirch     | Things that make Monday morning interesting, #2:
> okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
> ---------------+   running out of privileged ports?"

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
