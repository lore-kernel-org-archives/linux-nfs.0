From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Redhat 9 tcpmounting
Date: Mon, 30 Aug 2004 13:23:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41336286.7070504@RedHat.com>
References: <E1C1nil-0004L7-0H@sc8-sf-mx2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1psT-0004xp-Ll
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:23:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C1psP-0006v6-RU
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:23:32 -0700
To: randy <paries@knology.net>
In-Reply-To: <E1C1nil-0004L7-0H@sc8-sf-mx2.sourceforge.net>
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

randy wrote:

>Does anyone know the option I would have to enable in the config when
>building the kernel?
>  
>
CONFIG_NFSD_TCP=y but buyer beware.... FC1 will do this much better
plus its configured in by default....

>Also is there a enough performance gain to warrant recompiling the kernel?
>  
>
Well it depends on how clean your networks is. If you're getting a bunch 
of retransmits
using UDP, then TCP should smooth things out (since TCP is much better 
at dealing
with retransmits that RPC over UDP), but if the traffic is already 
pretty smooth, then
performance may decrease a very small amount due to the TCP overhead.....
But the gains of using a smarter transport (i.e. TCP) outweighs  the very
small performance hit... imho...

SteveD.
 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
