From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Tue, 3 Apr 2007 10:21:30 -0400
Message-ID: <4d569c330704030721i1b4c8d52t7a78bbf2e06fd221@mail.gmail.com>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
	<1175602407.4063.51.camel@localhost.localdomain>
	<89c397150704030618iee707a8v24b1cbeb0dd72502@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Phillip <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYjt4-00068e-PH
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 07:21:31 -0700
Received: from nz-out-0506.google.com ([64.233.162.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYjt5-00077V-T6
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 07:21:33 -0700
Received: by nz-out-0506.google.com with SMTP id i11so2186991nzi
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 07:21:31 -0700 (PDT)
In-Reply-To: <89c397150704030618iee707a8v24b1cbeb0dd72502@mail.gmail.com>
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

On 4/3/07, William A. (Andy) Adamson <andros@citi.umich.edu> wrote:
>
>
> On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
> > Andy,
> >
> > Thanks for you kindly reply.
> >
> > As your comment:
> > nfs/<your.host>@<YOUR.REALM>
> > and I google the following:
> > host/hostname@NT-DNS-REALM-NAME
> >
> > hostname is the host DNS name, for example, foobar.microsoft.com.
> > NT-DNS-REALM-NAME is the uppercase name of the Windows 2000 domain; for
> > example, RESKIT.COM.
>
> hostname is the dns name of your host. the realm name is the name of your
> kerberos domain.
> > I have two questions:
> > 1. What does the above term "host" mean? Hostname of NFS server, or
> > service(nfs)?
>
> this is kerberos speak.
>
> a kerberos service name has a "service" component (host, root, nfs, ldap,
> web, or whatever you want) followed by a "/" and then the dns hostname.
>
> NFSv4 requires that the NFSv4 server Kerberos service name is of the form
>
> nfs/<dnshostname>@<KERBEROS.REALM>
>
> the "host" service name is used by many other servers, but not by NFSv4.
>
> the NFSv4 client keytab name is unspecified. so, if you want you can place a
> keytab on the client
> to be used for NFSv4 - but it is not required.

Actually, the *current* client code requires a
"nfs/*@<KERBEROS.REALM>" key.  (This changes in (not yet released)
nfs-utils-1.1.0 so that other keys may be used.)

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
