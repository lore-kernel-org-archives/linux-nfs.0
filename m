From: Olaf Kirch <okir@suse.de>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 15:21:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040820132143.GC12371@suse.de>
References: <4125EA9F.3040304@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By9LG-0007Eo-Q8
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:22:02 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1By9LF-0002Fq-Ul
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:22:02 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <4125EA9F.3040304@bio.ifi.lmu.de>
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

On Fri, Aug 20, 2004 at 02:12:15PM +0200, Frank Steiner wrote:
> 2) We are currently testing kernel 2.6.8.1. The nfs behaviour seems
>    to have changed in some ways. Running e.g. "find /" on a diskless
>    client with kernel 2.4 would just hang when the server rebootet
>    and later go on when the server was back.
>    With 2.6.8.1, the find command will immediately abort and report
>    some stale nfs handles.

I reproduced this. Someone "improved" the init script to do this:

	/usr/sbin/exportfs -au
	killproc -n -KILL nfsd

so we first zap the exports tables, then stop all nfsds. Any NFS
requests received in the meanwhile will see ESTALE.

Try removing the exportfs call.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
