From: Peter Staubach <staubach@redhat.com>
Subject: Re: trace attached - Folders in NFS-share: permission denied,
 prob. not 16+ groups problem
Date: Mon, 08 May 2006 13:42:17 -0400
Message-ID: <445F82F9.3090804@redhat.com>
References: <445F0AAB.8040305@vwi.tu-dresden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fd9kR-0001dP-2H
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:42:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fd9kQ-0008HL-Pc
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:42:19 -0700
To: kolbe@vwitme011.vkw.tu-dresden.de
In-Reply-To: <445F0AAB.8040305@vwi.tu-dresden.de>
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

Steffen Kolbe wrote:

> -----------------------------------------------------------
> general question:
> Is their a real solution to use ~50 groups with nfs? Because we've 
> many project groups some team leaders, many crossover memberships over 
> some departments and .......
> How is this solved in bigger environments?
> ------------------------------------------------------------ 


The two most common solutions are either to use ACLs or use a security
flavor such as Kerberos.  The 16 group limit for AUTH_SYS is hard and
is an RPC limitation and not an NFS thing.

Unfortunately, ACLs are difficult to adminstrate and to manipulate for
ordinary users.  You could consider writing some tools to help your users
check and manipulate the ACLs as required.

The most common solution is to deploy Kerberos.  This eliminates the
16 group limit, but does incur the cost and complexity of deploying and
maintaining Kerberos.

The only other alternative that springs to mind is to rearchitect the
entire solution.  This is not usually something that people consider
doing...  :-)

    Thanx...

       ps


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
