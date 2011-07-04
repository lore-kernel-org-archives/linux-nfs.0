From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: git repo corrupted
Date: Mon, 04 Jul 2011 19:42:27 +0300
Message-ID: <4E11ED73.2020405@panasas.com>
References: <610AEC155EE2F04B99BDA23E6CAE1F1E18DA3955C2@KIT-MSX-07.kit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Mol, Xavier" <xavier.mol-Qicz5VY8OY0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:60378 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758383Ab1GDQmc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jul 2011 12:42:32 -0400
Received: by fxd18 with SMTP id 18so5412953fxd.11
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jul 2011 09:42:31 -0700 (PDT)
In-Reply-To: <610AEC155EE2F04B99BDA23E6CAE1F1E18DA3955C2-F7N7+xXlXnNgdz0fJnSz5ze48wsgrGvP@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not sure what went wrong earlier but cloning seems to be working
fine on my side right now so far (in "Receiving objects:" ...)

Can you please try again?

Thanks,

Benny

On 2011-07-04 18:11, Mol, Xavier wrote:
> Dear readers,
>=20
> I'm sorry if I'm wrong sending this notice to this list. I'm afraid, =
the
> last update of Benny Halevy for his project linux-pnfs.git (nfs41, pn=
fs)
> somewhere went wrong:
>=20
> $ git clone git://linux-nfs.org/~bhalevy/linux-pnfs.git
> Cloning into linux-pnfs...
> remote: fatal: Out of memory, realloc failed
> remote: aborting due to possible repository corruption on the remote =
side.
> fatal: early EOF
> fatal: index-pack failed
>=20
> This error occurred on two separate machines.
>=20
> Best regards,
> Xavier Mol
>=20
> ****
> Karlsruhe Institute of Technology (KIT)
> Steinbuch Centre for Computing (SCC)
>=20
> B.Sc. Xavier Mol
> GridKa Storage Support Manager and
> Head of the D-Grid dCache competence centre
>=20
> Hermann-von-Helmholtz-Platz 1
> Building 441
> 76344 Eggenstein-Leopoldshafen, Germany
> Telefon: +49 721 608 23041
> E-Mail: xavier.mol-Qicz5VY8OY0@public.gmane.org
> www.kit.edu
> KIT =96 University of the State of Baden-W=FCrttemberg and National L=
arge-scale
> Research Center of the Helmholtz Association
> ****
>=20

