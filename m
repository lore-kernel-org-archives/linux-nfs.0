From: "Fortier,Vincent [Montreal]" <Vincent.Fortier1-TdIlj1wg2M0@public.gmane.org>
Subject: RE: .Xauthority going stale (but not really)
Date: Tue, 19 Aug 2008 11:06:49 -0400
Message-ID: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7D@ECQCMTLMAIL2.quebec.int.ec.gc.ca>
References: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7A@ECQCMTLMAIL2.quebec.int.ec.gc.ca> <alpine.DEB.1.99.0808191627460.5165@sebohet.brgvxre.pu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <linux-nfs@vger.kernel.org>
To: "Tobi Oetiker" <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fwstl1-1.wul.qc.ec.gc.ca ([205.211.132.24]:14630 "EHLO
	ecqcmtlbh.quebec.int.ec.gc.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752700AbYHSP2Y convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 11:28:24 -0400
In-Reply-To: <alpine.DEB.1.99.0808191627460.5165-EjsAmf5DE5zIvOfxy3zmAzgUDZmNtoG9@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Message d'origine-----
> De : Tobi Oetiker [mailto:tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org]=20
> Envoy=E9 : 19 ao=FBt 2008 10:29
>=20
> Hi Vincent,
>=20
> Today Fortier,Vincent [Montreal] wrote:
>=20
> > Hi Thomas,
> >
> > I saw this post from you:
> > http://marc.info/?l=3Dlinux-nfs&m=3D121345713729459&w=3D2
> >
> > Have you found any way to solve the problem?
> >
> > Until now I have only seen that behaviour on a 64bit 2.6.24 kernel=20
> > (running debian etchnhalf).  I was about to check wether it does it=
 or=20
> > not in 32bit.
> >
> > Help greatly appreciated!
> >
>=20
>
> we have not yet solved the problem ... we see it with a=20
> 2.6.24 server and 2.6.24 client both 64bit ....
>=20
> since the message comes from the server, I imagine the probem=20
> is with the server ... but maybe the client strokes the=20
> server the wrong way ...
>=20
> did you figure anything out ?

It has to be client-side... I have not seen this with any previous kern=
els on the client-side (either old redhat 7.3 with 2.4.20 kernels or De=
bian Sarge with 2.6.8 to 2.6.23.17).  Also my server side is unchanged =
with a RHEL 4 (2.6.9 based kernel).

This is a totally new behaviour to me wich only occured with installati=
on of 64bit 2.6.24 kernel based debian etch clients (have not yet tried=
 32bit to confirm wether it is 2.6.24 OR amd64 based).  Although I cann=
ot reproduce it with a 2.6.23.17 32-bit.

If the problem reside with 2.6.24 kernel (and not 64bit specific) it sh=
ould be "easy" to git bisect where it comes from (although did not catc=
h the details of git bisect just yet :)

Note: Added linux-nfs in CC.

- vin
