From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kerberos+NFSv4: Security - Multiple sessions with same user.
 One  ticket for all?
Date: Wed, 26 Aug 2009 18:56:54 -0400
Message-ID: <1251327414.5226.98.camel@heimdal.trondhjem.org>
References: <f6ce31e30908260446g534bb70bxd742e35141ae99c1@mail.gmail.com>
	 <4A9521AE.3010900@s3group.cz>
	 <cbeb1f2b0908261409t21222b37le77f9afc03da038a@mail.gmail.com>
	 <f6ce31e30908261531m1ce99cd8m9ddde6269f0e536f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: le wang <lewang2000@gmail.com>,
	Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Carlos =?ISO-8859-1?Q?Andr=E9?= <candrecn@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53152 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbZHZW46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2009 18:56:58 -0400
In-Reply-To: <f6ce31e30908261531m1ce99cd8m9ddde6269f0e536f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-26 at 19:31 -0300, Carlos Andr=C3=A9 wrote:
> Wang,
>=20
> I know about "normal NFS" security issues... old times... "trust on
> host"... -_-'
> But I thought that this problem never happen using NFSv4+Kerberos5. I=
n
> resume, it's more secure then only NFS (without Kerberos), but still
> have alot of serious security problems...

This discussion keeps coming up, over and over again because people kee=
p
misunderstanding the Linux/*NIX security model.

The real issue is that a user with root privileges has a million ways o=
f
sniffing your passwords (e.g. as you type them in), reading your cached
data (e.g. /dev/kmem), or hijacking your processes (e.g. a /bin/ls
trojan). There is _nothing_ NFS can do to protect you against a
compromised root account.
Schemes like David Howells' keyrings can help against one or two of
these attacks, but cannot eliminate them all.

IOW: The problem isn't NFS. The exact same attacks can be used against
ssh, cifs, and all the other 'secure' protocols.

All Krb5 does is to make you safe against unprivileged users
impersonating you, and to make you safe against network packet sniffing
and spoofing.

Trond

