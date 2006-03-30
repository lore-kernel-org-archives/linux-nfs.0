From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: Re: NFS/Kernel Problem: getfh failed: Operation not
 permitted
Date: Thu, 30 Mar 2006 11:51:36 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0603301151200.18696@p34>
References: <Pine.LNX.4.64.0603300813270.18696@p34> <1143728720.8074.41.camel@lade.trondhjem.org>
 <Pine.LNX.4.64.0603300929340.18696@p34> <442C04BE.5000602@RedHat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FP0N3-0007vA-Pk
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 08:51:41 -0800
Received: from lucidpixels.com ([66.45.37.187] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FP0N2-0004LI-KS
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 08:51:42 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <442C04BE.5000602@RedHat.com>
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

Thanks, I will give this a try sometime soon and hopefully it'll fix the 
issue :)

Justin.

On Thu, 30 Mar 2006, Steve Dickson wrote:

> Justin Piszcz wrote:
>> Not running RH9, but running RHEL WS3, Taroon Update 4, however, the 
>> nfs-utils is 1.0.6-33EL, I know there were many fixes in 1.0.7+, could 
>> nfs-utils be the problem?  The kernel version in question is 
>> 2.4.21-31.ELa1smp.
> Try updating your nfs-utils to 1.0.6-43EL....
>
> steved.
>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
