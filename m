From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: nfs and iptables
Date: Tue, 8 Feb 2005 08:17:41 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502080815340.22564@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0502072228370.22564@harp.ngdc.noaa.gov>
 <1107873661.10364.13.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyX7h-0001kB-6V
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 07:17:53 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyX7f-00078j-Ds
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 07:17:52 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1107873661.10364.13.camel@lade.trondhjem.org>
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

On Tue, 8 Feb 2005, Trond Myklebust wrote:

> As I told you before. Lock recovery assumes that rpc.statd on the server can
> contact the clients after a server reboot. If you don't allow that, then it
> is quite possible for the client not to notice that the server has rebooted
> until after the grace period has expired.

sorry - i was thinking you were talking about *client* reboots (our problem)
before.  of course this makes sense.

> IOW: lock recovery may indeed "work" without this, but you are leaving
> yourself open to races that may crash your application and/or cause data
> corruption.

as i thought - i just needed to be able to explain this to our sysads
thoroughly to justify holes in the firewall.

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
