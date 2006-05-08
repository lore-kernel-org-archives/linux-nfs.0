From: Ramon van Alteren <ramon@vanalteren.nl>
Subject: Re: NFS limits?
Date: Mon, 8 May 2006 22:54:42 +0200
Message-ID: <3B58D89A-3B38-43C1-AFD3-D70ED4285C61@vanalteren.nl>
References: <445F8356.1030605@cnm.de>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdCkP-0005iC-Nk
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 13:54:29 -0700
Received: from cust.92.104.adsl.cistron.nl ([195.64.92.104] helo=router.forgottenland.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FdCkO-0000dg-IU
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 13:54:29 -0700
In-Reply-To: <445F8356.1030605@cnm.de>
To: Marten Lehmann <lehmann@cnm.de>
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

Hi,

On 8 May , 2006, at 7:43 PM, Marten Lehmann wrote:
> a mailserver of us is storing the messages on another server with  
> NFS through TCP. A lot of concurrent deliveries occur, but I can  
> only see about 8 nfs processes on the storage server. The  
> mailserver which accesses the storage often has very high I/O waits  
> (>400 seconds), because the NFS server doesn't respond in time. How  
> can I increase the NFS-processes on the storage server? Right NFS  
> is a real bottleneck and a lot of mails are delivered with a delay  
> of 1-3 hours.

I'm personally using gentoo which offers a tunable parameter on how  
many nfs deamons are started. I took a look in the init script that  
starts the nfs server and it appears to be a single parameter that  
you can supply to the nfs binary.

e.g. /usr/sbin/rpc.nfsd <no-of-nfs-processes>

AFAIK every client of the NFS server starts 4 nfs IOD (I/O deamons)  
to handle nfs by default.
It's probably possible to increase that as well, no idea how though.

Hope that helps ?

Grtz Ramon
--
If to err is human, I'm most certainly human.





-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
