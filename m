From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re:reason for mountd upcall
Date: Mon, 1 May 2006 08:44:27 -0700 (PDT)
Message-ID: <20060501154427.73634.qmail@web51615.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FaaZe-0000AV-S7
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 08:44:34 -0700
Received: from web51615.mail.yahoo.com ([206.190.39.127])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FaaZd-0001Dd-Jr
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 08:44:35 -0700
To: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
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

Ok got it.=20
I thought we can do away with relying on
reading files from /var/lib/nfs(for mountd upcall)
as kernel is aware of exports and their properties.
But these would introduce complexity in kernel code as
you said. Thanks

On Mon, 2006-05-01 at 06:44 -0700, mehta kiran wrote:
> Hi,
>      I see number of files in nfsd filesystem which
>      are readable and writable by user processes
>      like rpc.mountd(for upcalls).
>      Looks like same thing can be  done in kernel.
>      Is this only to move some
>      complex code from kernel to userland ?

Why on earth would we want to put crap like reverse
DNS, NIS, LDAP,
kerberos, ... in the kernel?

Cheers,
   Trond

"Trond Myklebust" <>  Add to Address Book  Add Mobile
Alert =20
To: "mehta kiran" <kiranmehta1981@yahoo.com>=20
CC:=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job ea=
sier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronim=
o
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
