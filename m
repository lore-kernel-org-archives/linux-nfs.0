From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: RE: 3 bugs with UDP mounts
Date: Tue, 23 Apr 2002 18:25:59 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204231731520.31993-100000@kenzo.iwr.uni-heidelberg.de>
References: <6440EA1A6AA1D5118C6900902745938E50CEBF@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17037E-00064i-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 09:26:04 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50CEBF@black.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 23 Apr 2002, Lever, Charles wrote:

> the client may also lose replies because of lack of socket buffer space.
> packets are received perfectly (thus no Rx error occurs) but the
> driver/network layer fails to copy the data to the RPC layer because
> there is not enough socket buffer space.  the network layer drops
> the packet.

Ouch, completely missed OOM situations in my earlier list. They are quite 
tricky because:
 - you never know when they hit you
 - you never know how much they last
 - some packets can go through and some cannot. Lots of drivers derived 
from Donald Becker's skeleton use a "rx_copybreak" limit to decide 
whether to just hand the (maximum sized) packet to the upper layers or 
allocate a properly sized skb and copy the packet there then hand it up. 
While allocation of a small skb in the second case might succeed 
(rx_copybreak is usually set to 200), the refilling of the Rx ring in the 
first case with a maximum sized one might fail.

A scenario that might happen is this: a client mounts some tree through 
NFS which is then used to serve web pages with apache + mods. There is no 
limit on number of simultaneously running apache and child processes. The 
machine works well most of the time, however, when it receives a high 
number of HTTP requests it spawns too many processes which exhaust 
memory... Several cases similar to this were reported to me (by people 
using the 3c59x driver as they thought it was related to the driver).

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
