From: Peter Staubach <staubach@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server
 when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 15:50:49 -0500
Message-ID: <43FE2029.7040205@redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>	 <1140711133.11831.27.camel@lade.trondhjem.org>	 <20060223192253.GG29177@hmsendeavour.rdu.redhat.com>	 <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com> <1140725969.7963.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCNQP-0002Aj-Kt
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 12:50:57 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCNQP-00052m-F2
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 12:50:57 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140725969.7963.17.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>>I would disagree somewhat.  There is a customer who has stumbled into this
>>situation.  We know that there is a bug here, that it has affected at one
>>customer, and the risk for fixing it is very small.  The gains might not be
>>obvious, but it would make at one customer even slightly happier.  That's
>>worth the small amount of effort that it would take to fix this.
>>    
>>
>
>Will the customer be happy to find out that the application breaks in
>much more nefarious ways as a result of a non-working lease?
>
>If this is Samba, then the correct answer is obvious: turn off oplocks
>in the configuration file since they won't ever work as expected anyway.
>

Well, it may or may not break, actually.  I would think that it would depend
upon what assumptions were being made by the application.

I would still suggest that the cost of fixing something which is clearly
broken is outweighed by the benefit of making a customer, at least 
temporarily,
happy.  If that customer is porting something from a system does support
F_SETLEASE, such as Solaris, and was happy with the way that it worked 
there,
then they may be happy with the current support of F_SETLEASE in Linux.

It is even possible that they were using leases for some reason instead of
file/record locking.  Who knows?  :-)

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
