From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: 2.4 vs 2.6
Date: Fri, 26 May 2006 01:19:05 -0700 (PDT)
Message-ID: <20060526081905.73641.qmail@web51609.mail.yahoo.com>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FjXXO-0000Mc-4R
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 01:19:14 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FjXXN-00044v-Tg
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 01:19:13 -0700
Received: from web51609.mail.yahoo.com ([206.190.38.214])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FjXXL-0004nv-HR
	for nfs@lists.sourceforge.net; Fri, 26 May 2006 01:19:14 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17526.44653.228663.713864@cse.unsw.edu.au>
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

1. I noticed that 2.6 kernel is not aware of=20
   exportfs until client tries to mount. It only
   after this that proc nfsd filesystem shows this
   in list of exports due to upcall.
   Was 2.4 kernel aware of exportfs when the
   filesystem was first exported or mounted ?

2. Can you let me know advantage 2.6 export approach
   over 2.4 export approach ?=20
   Is this approach required due to=20
   security/authentication integration with NFS(say=20
   ip->name conversion for security ) ?

Thanks,
 kiran

--- Neil Brown <neilb@suse.de> wrote:

> On Thursday May 25, kernel.vijay@gmail.com wrote:
> > Hi,
> > Can anyone tell me what are the differences in the
> linux kernel 2.4 version
> > and 2.6 version related to NFS implementation
>=20
> How much detail do you want?
>=20
> Apart from adding NFSv4, the main difference is the
> authentication
> cache with support for up-calls.
> In 2.4, exportfs and mountd had to tell the kernel
> about any export
> information that it might need to know.
> In 2.6, the kernel can ask mountd, and mountd will
> provide information
> on-demand.
>=20
> NeilBrown
>=20
>=20
>
-------------------------------------------------------
> All the advantages of Linux Managed Hosting--Without
> the Cost and Risk!
> Fully trained technicians. The highest number of Red
> Hat certifications in
> the hosting industry. Fanatical Support. Click to
> learn more
>
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D107521&bid=3D248729&dat=3D=
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
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications i=
n
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D107521&bid=3D248729&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
