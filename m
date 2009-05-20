From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS-CIFS locking
Date: Wed, 20 May 2009 11:22:33 -0400
Message-ID: <20090520112233.40e0b905@tlielax.poochiereds.net>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: <linux-nfs@vger.kernel.org>
To: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36737 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755333AbZETPWn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 11:22:43 -0400
In-Reply-To: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA-WnaG5mLaJUsadWZoJ9kThg@public.gmane.org_nt.nt.pmc-sierra.bc.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 May 2009 23:11:40 -0700
"Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:

>=20
> Hi List,
> I have a use case where I will export one share through=A0 samba, FTP=
 and NFS. Is there any way to achieve cross protocol locking? I am usin=
g Linux kernel 2.6.18.=20
> Any inputs highly appreciated.
>=20

=46TP doesn't really do any locking so that shouldn't be an issue. NFS
just uses regular posix locks. I think samba by default uses posix
locks on the backend (subject to the setting of the "posix locking"
parameter in smb.conf), so I that that should also work there.

If you're having problems with that, then you may have better luck
asking this question on one of the samba mailing lists...

Cheers,
--=20
Jeff Layton <jlayton@redhat.com>
