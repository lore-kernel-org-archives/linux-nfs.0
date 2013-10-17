Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51558 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762289Ab3JQVdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Oct 2013 17:33:07 -0400
Date: Fri, 18 Oct 2013 08:32:53 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Wangminlan <wangminlan@huawei.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131018083253.40e8881e@notabene.brown>
In-Reply-To: <CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
	<20131014174540.GA27747@fieldses.org>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
	<20131015154918.GA6117@fieldses.org>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEF9FD9@szxema505-mbs.china.huawei.com>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
	<CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/5sLMzXLz/Xp4kiYIvocnCZ0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/5sLMzXLz/Xp4kiYIvocnCZ0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 17 Oct 2013 09:14:02 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Hi-
>=20
> 281         if (ident[0] =3D=3D '\0')
> 282                 return MCL_ANONYMOUS;
> 283         if (ident[0] =3D=3D '@') {
> 284 #ifndef HAVE_INNETGR
> 285                 xlog(L_WARNING, "netgroup support not compiled in");
> 286 #endif
> 287                 return MCL_NETGROUP;
> 288         }
> 289         for (sp =3D ident; *sp; sp++) {
> 290                 if (*sp =3D=3D '*' || *sp =3D=3D '?' || *sp =3D=3D '[=
')
> 291                         return MCL_WILDCARD;
> 292                 if (*sp =3D=3D '/')
> 293                         return MCL_SUBNETWORK;
> 294                 if (*sp =3D=3D '\\' && sp[1])
> 295                         sp++;
> 296         }
>=20
> is still in play today.  The "host_pton()" code you posted was added by c=
ommit 502edf1d just after this paragraph.  But here is what that commit rep=
laced.
>=20
> -       /* check for N.N.N.N */
> -       sp =3D ident;
> -       if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=3D '.') r=
eturn MCL_FQDN;
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=3D =
'.') return MCL_F
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=3D =
'.') return MCL_F
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=3D =
'\0') return MCL_
> -       /* we lie here a bit. but technically N.N.N.N =3D=3D N.N.N.N/32 :=
) */
> -       return MCL_SUBNETWORK;
> +
> +       /*
> +        * Treat unadorned IP addresses as MCL_SUBNETWORK.
> +        * Everything else is MCL_FQDN.
> +        */
> +       ai =3D host_pton(ident);
> +       if (ai !=3D NULL) {
> +               freeaddrinfo(ai);
> +               return MCL_SUBNETWORK;
> +       }
> +
> +       return MCL_FQDN;
>  }
>=20
> The replaced logic also treats IP addresses as MCL_SUBNETWORK.  That's fr=
om commit 54669c98 in 2005.  Neil, do you remember why this semantic change=
 was made?
>=20

See this thread:

  http://marc.info/?t=3D110993941000003&r=3D1&w=3D2

It was a simple (though possibly flawed) solution to clearly differentiate
those addresses where DNS looked might be needed, and those where it was no=
t.

I may have more to say later but I have to rush off now, so thought I'd just
post this anyway.

NeilBrown


>=20
>=20
> On Oct 17, 2013, at 3:16 AM, Wangminlan <wangminlan@huawei.com> wrote:
>=20
> > Hi,=20
> > 	I went through the code of nfs-utils, check the function client_gettyp=
e in support/export/client.c:
> > in nfs-utils-1-2-9-rc6, and in nfs-utils-1.2.6, they have this implemen=
tation in the final part:
> > 770         /*
> > 771          * Treat unadorned IP addresses as MCL_SUBNETWORK.
> > 772          * Everything else is MCL_FQDN.
> > 773          */
> > 774         ai =3D host_pton(ident);
> > 775         if (ai !=3D NULL) {
> > 776                 freeaddrinfo(ai);
> > 777                 return MCL_SUBNETWORK;
> > 778         }
> > 779=20
> > 780         return MCL_FQDN;
> > 781 }
> >=20
> > while back in days of nfs-utils-1.0.7: client_gettype looks like this:
> > 277 client_gettype(char *ident)
> > 278 {
> > 279         char    *sp;
> > 280=20
> > 281         if (ident[0] =3D=3D '\0')
> > 282                 return MCL_ANONYMOUS;
> > 283         if (ident[0] =3D=3D '@') {
> > 284 #ifndef HAVE_INNETGR
> > 285                 xlog(L_WARNING, "netgroup support not compiled in");
> > 286 #endif
> > 287                 return MCL_NETGROUP;
> > 288         }
> > 289         for (sp =3D ident; *sp; sp++) {
> > 290                 if (*sp =3D=3D '*' || *sp =3D=3D '?' || *sp =3D=3D =
'[')
> > 291                         return MCL_WILDCARD;
> > 292                 if (*sp =3D=3D '/')
> > 293                         return MCL_SUBNETWORK;
> > 294                 if (*sp =3D=3D '\\' && sp[1])
> > 295                         sp++;
> > 296         }
> > 297         return MCL_FQDN;
> > 298 }
> >=20
> > It's simple, and client like "192.168.0.21" is treated as MCL_FQDN.=20
> > I tried the same operation in this version, there's no such problem as =
in nfs-utils-1.2.1 and nfs-utils-1.2.6.
> >=20
> >> -----Original Message-----
> >> From: linux-nfs-owner@vger.kernel.org
> >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Wangminlan
> >> Sent: Wednesday, October 16, 2013 9:23 AM
> >> To: J. Bruce Fields
> >> Cc: linux-nfs@vger.kernel.org
> >> Subject: RE: Different sequence of "exportfs" produce different effect=
s on nfs
> >> client mounts
> >>=20
> >> Hi, Bruce,
> >> 	The nfs-utils on my box is nfs-utils-1.2.1-2.6.6, which is Suse distr=
ibuted.
> >> 	I tried the same experiment on fedora18, which use nfs-utils-1.2.6, a=
nd
> >> got the same result.
> >> 	I go through the code of support/export/client.c, found that in
> >> client_get_type(), when the client is specified as an IP address(which=
 can not
> >> be resolved as an FQDN), it actually return the result: MCL_SUBNETWORK.
> >> 	I guess that's the reason that the client "192.168.0.21" and
> >> "192.168.0.0/16" both are sorted to the same category: MCL_SUBNETWORK,
> >> so the order of exports matters here.
> >> 	Is this what exportfs and mountd mean to be?
> >> B.R
> >> Minlan Wang
> >>=20
> >> On Tuesday, October 15, 2013 at 03:49AM +0000, Bruce Fields wrote:
> >>> Looking at the mountd code....
> >>>=20
> >>> Looks like utils/mountd/cache.c makes no special effort to prioritize
> >>> exports except in the v4root and crossmnt cases, neither an issue in
> >>> your case.
> >>>=20
> >>> So yes it depends on ordering. From man exports:
> >>>=20
> >>> 	 If a client matches more than one of the specifications above,
> >>> 	 then the first match from the above list order takes precedence
> >>> 	 - regardless  of the  order they appear on the export line.
> >>> 	 However, if a client matches more than one of the same type of
> >>> 	 specification (e.g.  two  netgroups), then  the  first  match
> >>> 	 from  the order they appear on the export line takes
> >>> 	 precedence.
> >>>=20
> >>> The order given is: single host, IP networks, wildcards, negroups,
> >>> anonymous.
> >>>=20
> >>> So the single host exports should have taken precedence.
> >>>=20
> >>> The code here does look like it corectly implements the above orderin=
g.
> >>>=20
> >>> What version of nfs-utils are you using?
> >>>=20
> >>> --b.
> >>>=20
> >>> On Tue, Oct 15, 2013 at 06:39:59AM +0000, Wangminlan wrote:
> >>>> On Mon, Oct 14, 2013 at 16:46 +0000, Bruce Fields wrote:
> >>>>> On Mon, Oct 14, 2013 at 02:16:58AM +0000, Wangminlan wrote:
> >>>>>> =E3=80=80=E3=80=80Hi,
> >>>>>> =E3=80=80=E3=80=80         I=E2=80=99ve got a problem on the nfs e=
xportfs command. I=E2=80=99m
> >>> not
> >>>>> sure if this is the right place to ask this, if not, can you please=
 tell me
> >>> where?
> >>>>>>=20
> >>>>>> =E3=80=80=E3=80=80         Here=E2=80=99s what I need:
> >>>>>> =E3=80=80=E3=80=801. I have a folder named /mnt/fs1 to be exported.
> >>>>>> =E3=80=80=E3=80=802. All the host in subnetwork 192.168.0.0/16 sho=
uld be able access
> >>> this
> >>>>> folder, but their root should be squashed.
> >>>>>> =E3=80=80=E3=80=803. Some specified host in the same subnetwork ca=
n gain the root
> >>>>> permission on the folder, for example: 192.168.0.21, 192.168.0.22.
> >>>>>>=20
> >>>>>> =E3=80=80=E3=80=80I=E2=80=99ve got a SLES11SP1 box as the nfs serv=
er, the nfs clients are
> >>> SLES11SP1,
> >>>>> too, and the protocol used between clients and server are NFSv3.
> >>>>>> =E3=80=80=E3=80=80Here are the commands I used to do the export:
> >>>>>> =E3=80=80=E3=80=80#exportfs =E2=80=93o rw,root_squash 192.168.0.0/=
16:/mnt/fs1
> >>>>>> =E3=80=80=E3=80=80#exportfs =E2=80=93o rw,no_root_squash 192.168.0=
.21:/mnt/fs1
> >>>>>> =E3=80=80=E3=80=80#exportfs =E2=80=93o rw,no_root_squash 192.168.0=
.22:/mnt/fs1
> >>>>>> =E3=80=80=E3=80=80After this, everything works as expected.
> >>>> After this, the contents of /proc/net/rpc/auth.unix.ip/content and
> >>> /proc/net/rpc/nfsd.export/content are:
> >>>> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content
> >>>> 	#class IP domain
> >>>> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
> >>>> 	nfsd 0.0.0.0 -test-client-
> >>>> 	# nfsd 100.43.189.1 -no-domain-
> >>>>=20
> >>>> 	NV200_01:/proc/net/rpc # cat nfsd.export/content
> >>>> 	#path domain(flags)
> >>>> 	/mnt/fs1
> >>> 	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=3D0,anonuid=3D42=
94967
> >>> 295,anongid=3D4294967295)
> >>>> 	/mnt/fs1
> >>> 	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree
> >>> _check,uuid=3D13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> >>>> 	# /mnt/fs1
> >>> 	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree
> >>> _check,uuid=3D13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> >>>> Besides, the content of /var/lib/nfs/etab is:
> >>>> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab
> >>>> 	/mnt/fs1
> >>> 	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
> >>>=20
> >> _all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D6553
> >>> 4)
> >>>> 	/mnt/fs1
> >>> 	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
> >>>=20
> >> _all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D6553
> >>> 4)
> >>>> 	/mnt/fs1
> >>> 	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_
> >>>=20
> >> all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D65534
> >>> )
> >>>>>>=20
> >>>>>> =E3=80=80=E3=80=80But, after the following operations:
> >>>>>> =E3=80=80=E3=80=80#exportfs =E2=80=93u 192.168.0.0/16:/mnt/fs1    =
          /* Delete
> >>> this
> >>>>> export */
> >>>>>> =E3=80=80=E3=80=80# exportfs =E2=80=93o rw,root_squash 192.168.0.0=
/16:/mnt/fs1
> >>> /*
> >>>>> And add it again */
> >>>>>> =E3=80=80=E3=80=80Hosts on 192.168.0.21 and 192.168.0.22 doesn=E2=
=80=99t get root
> >>> permission
> >>>>> any more. when I tried to write a file, it complains about =E2=80=
=9CPermission
> >>> denied=E2=80=9D.
> >>>>>>=20
> >>>>>> =E3=80=80=E3=80=80So, does the order of exportfs command has somet=
hing to do the
> >>> final
> >>>>> result? Or am I doing something wrong?
> >>>> After this, the contents of /proc/net/rpc/auth.unix.ip/content and
> >>> /proc/net/rpc/nfsd.export/content are:
> >>>> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content
> >>>> 	#class IP domain
> >>>> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
> >>>> 	nfsd 0.0.0.0 -test-client-
> >>>> 	# nfsd 100.43.189.1 -no-domain-
> >>>>=20
> >>>> 	NV200_01:/proc/net/rpc # cat nfsd
> >>>> 	nfsd         nfsd.export/ nfsd.fh/
> >>>> 	NV200_01:/proc/net/rpc # cat nfsd
> >>>> 	nfsd         nfsd.export/ nfsd.fh/
> >>>> 	NV200_01:/proc/net/rpc # cat nfsd.export/content
> >>>> 	#path domain(flags)
> >>>> 	/mnt/fs1
> >>> 	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=3D0,anonuid=3D42=
94967
> >>> 295,anongid=3D4294967295)
> >>>> 	/mnt/fs1
> >>> 	192.168.0.0/16,192.168.0.21(rw,root_squash,sync,wdelay,no_subtree_ch
> >>> eck,uuid=3D13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> >>>> And the content of /var/lib/nfs/etab is:
> >>>> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab
> >>>> 	/mnt/fs1
> >>> 	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_
> >>>=20
> >> all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D65534
> >>> )
> >>>> 	/mnt/fs1
> >>> 	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
> >>>=20
> >> _all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D6553
> >>> 4)
> >>>> 	/mnt/fs1
> >>> 	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
> >>>=20
> >> _all_squash,no_subtree_check,secure_locks,acl,anonuid=3D65534,anongid=
=3D6553
> >>> 4)
> >>>>>=20
> >>>>> That sounds like a bug.  The contents of
> >>>>> /proc/net/rpc/auth.unix.ip/content and
> >> /proc/net/rpc/nfsd.export/content
> >>>>> after getting the above "permission denied" might be interesting.
> >> =13=EF=BF=BD=EF=BF=BD=EC=B9=BB=1C=EF=BF=BD&=EF=BF=BD~=EF=BF=BD&=EF=BF=
=BD=18=EF=BF=BD=EF=BF=BD+-=EF=BF=BD=EF=BF=BD=DD=B6=17=EF=BF=BD=EF=BF=BDw=EF=
=BF=BD=EF=BF=BD=CB=9B=EF=BF=BD=EF=BF=BD=EF=BF=BDm=EF=BF=BDb=EF=BF=BD=EF=BF=
=BDg~=C8=A7=EF=BF=BD=17=EF=BF=BD=EF=BF=BD=DC=A8}=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=C6=A0z=EF=BF=BD&j:+v=EF=BF=BD=EF=BF=BD=EF=BF=BD
> >>=20
> > =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ+=EF=BF=BD=EF=BF=BD+zf=EF=BF=BD=
=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD~=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BDi=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=BF=
=BD=EF=BF=BD?=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD)=DF=A2=1Bf
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--Sig_/5sLMzXLz/Xp4kiYIvocnCZ0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmBXhTnsnt1WYoG5AQIkoQ/+NQBpkSsJralbYD1MNNcV4Z7xUbAERr1D
eiyZPHtWjChbUkTxhAeAzskdTK1ZNS89juIPr0Qihh0I6PkrWMUwbpp2C/XfJEFc
5Au5o4BbxhsGGi2SW84Dej/qfDAl4DwGthyVY7sPAzBelBIB93lx6+hghVGE8zn8
NyFjWZdC0tQaM3Zl5w7yvjuyN8kAMOIVZyLJfDSfaak05KNtOWZeaidctsO/xoFj
TFvZJLmsPyNCwhX7LjPJbEA7RmkiXdvnOYb0imHYaQFjR2P/+jXtYujsS5Mb6wPk
xslOa6jEE2HfP7dWfNKC0iHyf+O7HOvEJF+9rCx++4pJ9PjbAxuZJ505fULgxFRA
Z0WDMGcy1GDSwCf+vIKxSKidxhaX0POYf+jxZ4hbWAttC0onYeqMnm1LWQK6+n+B
DTdJrtiELeADudqCHx9gEgtItWvsezTUyCfH7TvvpIMWaxZEF8M19DmYENfbobY6
jGABqgANvsNzjVdeIw2UAoLgb9wnpORpQv2BIwmgmGr6LxfsI1peb5g85zafsrfF
THn+jc/8A//jhsqqSfKqYyra8YMyFLuzcQbf+8qu9EOIbyI0AIUNTQUQ+5jhjlZu
EGFO1gQjIn+8/FUETM9u+8HrlEJlZ5QpCHMSfwLEZN/qfFIWs+fp+R3en1r4X3nL
ZAG5XgTtUy4=
=rr+X
-----END PGP SIGNATURE-----

--Sig_/5sLMzXLz/Xp4kiYIvocnCZ0--
