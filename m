From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: /var/lib/nfs/v4recovery
Date: Thu, 9 Mar 2006 23:44:11 -0800 (PST)
Message-ID: <20060310074411.78426.qmail@web51612.mail.yahoo.com>
References: <20060310071803.8229.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHcIM-0007ny-Jq
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 23:44:18 -0800
Received: from web51612.mail.yahoo.com ([68.142.224.85])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FHcIL-0002dQ-5d
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 23:44:18 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20060310071803.8229.qmail@web51601.mail.yahoo.com>
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
   I could see that it is mentioned that
   /var/lib/nfs/v4recovery needs to be created
   for NFSv4 at=20
=20
http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html.
   1. What is this file for ?
      As NFSv4 uses lease based locking , it does
"NOT"
      create files on persistent storage.
      And its state could be stored  =20
      in /var/lib/nfs/statd/state , right ?

   2. I have read that lease time for NFSV4 can be=20
      chnaged by setting value in
      /proc/fs/nfsd/nfsv4leasetime. In case i dont
      set lease period  , is grace period set by user
      considered as the lease time ?

Thanks,
 kiran








--- mehta kiran <kiranmehta1981@yahoo.com> wrote:

> Hi,
>    I could see that it is mentioned that
>    /var/lib/nfs/v4recovery needs to be created
>    for NFSv4 at=20
> =20
>
http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html.
>    1. What is this file for ?
>       As NFSv4 uses lease based locking , it does
>       create files on persistent storage.
>       And its state could be stored  =20
>       in /var/lib/nfs/statd/state , right ?
>=20
>    2. I have read that lease time for NFSV4 can be=20
>       chnaged by setting value in
>       /proc/fs/nfsd/nfsv4leasetime. In case i dont
>       set lease period  , is grace period set by
> user
>       considered as the lease time ?
>=20
> Thanks,
>  kiran
>     =20
>=20
>     =20
>=20
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam
> protection around=20
> http://mail.yahoo.com=20
>=20
>=20
>
-------------------------------------------------------
> This SF.Net email is sponsored by xPML, a
> groundbreaking scripting language
> that extends applications into web and mobile media.
> Attend the live webcast
> and join the prime developer group breaking into
> this new coding territory!
>
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
