From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 15:41:07 -0400
Message-ID: <20080904194107.GB13981@fieldses.org>
References: <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be> <20080904194046.GA13981@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47471 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754309AbYIDTlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 15:41:09 -0400
In-Reply-To: <20080904194046.GA13981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 03:40:46PM -0400, bfields wrote:
> On Thu, Sep 04, 2008 at 09:38:34PM +0200, Fran=C3=A7ois Valenduc wrot=
e:
> > Kevin Coffman a =C3=A9crit :
> >> This may be a stupid question, but can you access the mount using
> >> auth_sys?  As I think I said before, it looks like the Kerberos pa=
rt
> >> is working.  (Unless there are errors on the client side from
> >> rpc.gssd.)
> >>
> >>  =20
> > I finally found a solution to the problem.
>=20
> Great!
>=20
> > It seems that it's needed to =20
> > compile both NFS v3 and v4 server support to make kerberos support =
=20
> > working. I find that a bit strange, but with this kernel configurat=
ion, =20
> > it is working fine. I find that a bit strange since I export the =20
> > filesystem as NFS3.
> > Should we consider this as a bug ? I am running kernel 2.6.26.3.
>=20
> Yes, that would be a bug!  But: are you sure gss support was built in=
 on
> the server?

(Could you send a copy of the non-working config?)

--b.
