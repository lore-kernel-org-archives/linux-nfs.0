From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 12:31:07 +0100
Message-ID: <20041209113107.GE15055@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com> <41B74551.5040908@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcMVs-0005FU-TH
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:31:12 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcMVq-0004px-CX
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:31:12 -0800
To: Mike Waychison <Michael.Waychison@Sun.COM>
In-Reply-To: <41B74551.5040908@sun.com>
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

On Wed, Dec 08, 2004 at 01:17:53PM -0500, Mike Waychison wrote:
> This has been bugging me for a while.  The fact that we are limitting
> ourselves to a single nfs mount per port.  From what I can tell, Solaris
> shares the transports between nfs mounts from the same server and saves
> themselves a lot of trouble with running out of port numbers in doing so.

Shouldn't we allow NFS mounts to use non-privileged ports? Many
environments don't really care about the "security" provided by privileged
ports, but would be more than happy if they can run with a few hundred
NFS mounts

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
