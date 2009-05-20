From: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: NFS-CIFS locking
Date: Wed, 20 May 2009 09:12:24 -0700
Message-ID: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca> <20090520112233.40e0b905@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <linux-nfs@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bby1mta03.pmc-sierra.com ([216.241.235.118]:59904 "EHLO
	bby1mta03.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755725AbZETQMY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 12:12:24 -0400
In-Reply-To: <20090520112233.40e0b905-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

Thanks for your reply. Basically what I want is "the file which is used=
 under CIFS share should not get overwritten from  a nfs share and vice=
 versa." . I might be looking for mandatory file locking in nfs share.=20

Thanks
Anoop

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Wednesday, May 20, 2009 8:53 PM
> To: Anoop P.A.
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS-CIFS locking
>=20
> On Tue, 19 May 2009 23:11:40 -0700
> "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:
>=20
> >
> > Hi List,
> > I have a use case where I will export one share through=A0 samba, F=
TP and
> NFS. Is there any way to achieve cross protocol locking? I am using L=
inux
> kernel 2.6.18.
> > Any inputs highly appreciated.
> >
>=20
> FTP doesn't really do any locking so that shouldn't be an issue. NFS
> just uses regular posix locks. I think samba by default uses posix
> locks on the backend (subject to the setting of the "posix locking"
> parameter in smb.conf), so I that that should also work there.
>=20
> If you're having problems with that, then you may have better luck
> asking this question on one of the samba mailing lists...
>=20
> Cheers,
> --
> Jeff Layton <jlayton@redhat.com>
