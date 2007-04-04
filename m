From: Phillip <phuang@plasmon.cn>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Wed, 04 Apr 2007 10:17:21 +0800
Message-ID: <1175653041.2998.11.camel@milan>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
	<1175602407.4063.51.camel@localhost.localdomain>
	<89c397150704030618iee707a8v24b1cbeb0dd72502@mail.gmail.com>
	<4d569c330704030721i1b4c8d52t7a78bbf2e06fd221@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, mzeng@plasmon.cn
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYv4J-0005Ul-5U
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 19:17:51 -0700
Received: from [211.97.48.10] (helo=zh.plasmon.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYv4G-0005Hx-QP
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 19:17:53 -0700
In-Reply-To: <4d569c330704030721i1b4c8d52t7a78bbf2e06fd221@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello Andy & Kevin,

Thanks for your kindly help.

Yes, I create the keytab by "nfs/nfsv4@PLASMON.SIT" and start rpc.gssd
and rpc.svcgssd successfully. nfsv4 is the hostname of NFS server, and
PLASMON.SIT is the AD domain.

When Set Windows2K as KDC for NFSv4, is it necessary to user Ktpass
tools to create keytab in the KDC server(Windows), and copy the keytabs
to NFS server and clients?

If so, it seems to be complicated and causes security problems while
users have to log and access KDC server frequently.

Is there other easy way to do this? We do not want to make the end-users
confused.


Regards,
Phillip 



On Tue, 2007-04-03 at 10:21 -0400, Kevin Coffman wrote:
> On 4/3/07, William A. (Andy) Adamson <andros@citi.umich.edu> wrote:
> >
> >
> > On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
> > > Andy,
> > >
> > > Thanks for you kindly reply.
> > >
> > > As your comment:
> > > nfs/<your.host>@<YOUR.REALM>
> > > and I google the following:
> > > host/hostname@NT-DNS-REALM-NAME
> > >
> > > hostname is the host DNS name, for example, foobar.microsoft.com.
> > > NT-DNS-REALM-NAME is the uppercase name of the Windows 2000 domain; for
> > > example, RESKIT.COM.
> >
> > hostname is the dns name of your host. the realm name is the name of your
> > kerberos domain.
> > > I have two questions:
> > > 1. What does the above term "host" mean? Hostname of NFS server, or
> > > service(nfs)?
> >
> > this is kerberos speak.
> >
> > a kerberos service name has a "service" component (host, root, nfs, ldap,
> > web, or whatever you want) followed by a "/" and then the dns hostname.
> >
> > NFSv4 requires that the NFSv4 server Kerberos service name is of the form
> >
> > nfs/<dnshostname>@<KERBEROS.REALM>
> >
> > the "host" service name is used by many other servers, but not by NFSv4.
> >
> > the NFSv4 client keytab name is unspecified. so, if you want you can place a
> > keytab on the client
> > to be used for NFSv4 - but it is not required.
> 
> Actually, the *current* client code requires a
> "nfs/*@<KERBEROS.REALM>" key.  (This changes in (not yet released)
> nfs-utils-1.1.0 so that other keys may be used.)
> 
> K.C.
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
