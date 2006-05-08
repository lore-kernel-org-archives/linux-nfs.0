From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: Re: Re: trace attached - Folders in NFS-share: permission denied,
 prob. not 16+ groups problem
Date: Mon, 08 May 2006 21:36:58 +0200
Message-ID: <445F9DDA.7090007@vwi.tu-dresden.de>
References: <445F0AAB.8040305@vwi.tu-dresden.de> <445F82F9.3090804@redhat.com>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdBXo-0007Sv-TI
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 12:37:24 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FdBXl-0006F1-VB
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 12:37:24 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <445F82F9.3090804@redhat.com>
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

Thanks.

Perhaps something in background to the system I would install/use. 
Perhaps it's better for tips, how could I resolve this problem.

Server:
2x Win2003R2 for user management and "windows things"
  -AD (LDAP, Kerberos) with SFU-schema
  -because "easy" to install and most "work-ready" after install
   (I'm started over years with MS, the user DB was also old MS. I would 
migrate most to Linux, but
    I'm not ready with "learning" Linux. LDAP+Kerberos server on Linux 
isn't easy to understand/
    install/configure for a single person, so it's MS AD because it must 
work and it's easyer for me)
2x Debian (active-passive cluster) for server works: file, mail, print, 
......
  -all files/luns/config files mounted from active node via FC-SAN 
before starting services
  -nss via LDAP/nss_ldap against the MS AD 
  -pam/password via pam_krb5 against the MS AD
  -NFS-Server, ....

Clients, Debian:
-nss via LDAP/nss_ldap against the MS AD
-pam/password via pam_krb5 against the MS AD
... until here this works all fine...
-network directories via NFS against the debian cluster ....so the plan

I don't like ACLs, so NFS with more groups is the better and easyer way 
for me and the users in my opinion. Isn't ?
Is their a faq/help or so available, how to configure nfs for kerberos 
(without auth_sys)?

Thanks and best regards
Steffen


Peter Staubach wrote:

> Steffen Kolbe wrote:
>
>> -----------------------------------------------------------
>> general question:
>> Is their a real solution to use ~50 groups with nfs? Because we've 
>> many project groups some team leaders, many crossover memberships 
>> over some departments and .......
>> How is this solved in bigger environments?
>> ------------------------------------------------------------ 
>
>
>
> The two most common solutions are either to use ACLs or use a security
> flavor such as Kerberos.  The 16 group limit for AUTH_SYS is hard and
> is an RPC limitation and not an NFS thing.
>
> Unfortunately, ACLs are difficult to adminstrate and to manipulate for
> ordinary users.  You could consider writing some tools to help your users
> check and manipulate the ACLs as required.
>
> The most common solution is to deploy Kerberos.  This eliminates the
> 16 group limit, but does incur the cost and complexity of deploying and
> maintaining Kerberos.
>
> The only other alternative that springs to mind is to rearchitect the
> entire solution.  This is not usually something that people consider
> doing...  :-)
>
>    Thanx...
>
>       ps




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
