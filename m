From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6 support for NFSv2 server.
Date: Thu, 26 May 2011 14:36:09 -0400
Message-ID: <CCEDE6F7-12A9-4308-A178-873FD972994C@oracle.com>
References: <7C481A0A0BBE9E4BA110F26D7A2BFFDC026E7C46@nodmx01.igglobal.com> <BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw@mail.gmail.com> <BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=windows-1252
Cc: linux-nfs@vger.kernel.org
To: Upakul Barkakaty <upakul@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28739 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308Ab1EZSgT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 14:36:19 -0400
In-Reply-To: <BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 26, 2011, at 2:27 PM, Upakul Barkakaty wrote:

> Hi all,
>=20
> I have been contemplating about using an appropriate server that woul=
d
> support NFSv2 over IPv6.
>=20
> RHEL5 doesn=92t support IPv6 over NFS by default. I tried installing =
a
> few libraries and patches but it doesn=92t seem to be working out yet
> due to some missing dependencies.
>=20
> RHEL6 *seems* to support just the NFS client over IPv6. Further it
> seems to support only NFSv4 as it generates an error if I force the
> NFS version to 2 in the mount options[mount.nfs: an incorrect mount
> option was specified].

NFSv2 over IPv6 should work on Linux clients.  I don't think I ever exp=
licitly tested it, though, so there could be bugs.

How are you "forcing" it?

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




