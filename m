From: "randy" <paries@knology.net>
Subject: RE: Redhat 9 tcpmounting
Date: Mon, 30 Aug 2004 12:38:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C1q7J-0003nc-2c@sc8-sf-mx1.sourceforge.net>
References: <41336286.7070504@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1q7J-0007pY-IH
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:38:53 -0700
Received: from smtp.knology.net ([24.214.63.101])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1C1q7J-0003nc-2c
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:38:53 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <41336286.7070504@RedHat.com>
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

Thanks for the response

What is  "FC1"

I am connect between two boxes with a crossover and gigabit nic cards

I a, trying to figure out ways to get rid of this error message on my
console about a host not responding.
I was thinking maybe tcp would help

randy


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Steve Dickson
Sent: Monday, August 30, 2004 12:23 PM
To: randy
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Redhat 9 tcpmounting

randy wrote:

>Does anyone know the option I would have to enable in the config when 
>building the kernel?
>  
>
CONFIG_NFSD_TCP=y but buyer beware.... FC1 will do this much better plus its
configured in by default....

>Also is there a enough performance gain to warrant recompiling the kernel?
>  
>
Well it depends on how clean your networks is. If you're getting a bunch of
retransmits using UDP, then TCP should smooth things out (since TCP is much
better at dealing with retransmits that RPC over UDP), but if the traffic is
already pretty smooth, then performance may decrease a very small amount due
to the TCP overhead.....
But the gains of using a smarter transport (i.e. TCP) outweighs  the very
small performance hit... imho...

SteveD.
 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop FREE Java Enterprise
J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
