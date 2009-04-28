From: =?ISO-8859-1?Q?Rasmus_B=F8g_Hansen?= <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>
Subject: Re: PROBLEM: nfsd crashes in 2.6.29
Date: Tue, 28 Apr 2009 22:07:06 +0200
Message-ID: <49F761EA.1080303@msconsult.dk>
References: <20090428164133.GP17891@fieldses.org> <49D218C8.2040503@msconsult.dk> <20090401185759.GD8899@fieldses.org> <20090402105943.14031ff3mhfka6bk@ssl.msconsult.dk> <25153.1240939886@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from port254.ds1-he.adsl.cybercity.dk ([217.157.198.197]:41042 "EHLO
	gere.msconsult.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbZD1UIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 16:08:05 -0400
In-Reply-To: <25153.1240939886@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells skrev:
> J. Bruce Fields <bfields@fieldses.org> wrote:
>=20
>>>> Without trying to figure out where that is, just looking at the
>>>> offset...  That would be consistent with current_cred()->security =
being
>>>> NULL, since the cred_sid(cred) in inode_has_perm does tsec->sid, w=
here
>>>> tsec is
>=20
> It oughtn't to be possible...  Unless, perhaps, the credentials have =
been
> freed.  During the process of freeing the creds, the security pointer=
 is
> cleared.
>=20
> Are you running with CONFIG_DEBUG_SLAB=3Dn?  If so, would it be possi=
ble to flip
> it to =3Dy?

I have it turned off and now I am running 2.6.29.2 fine without selinux=
=20
(which I didn't use).

I can try to turn it on but I won't be near the server for about two=20
weeks as I am going on a training course and noone else uses the NFS se=
rver.

Regards
/Rasmus

--=20
Rasmus B=F8g Hansen
MSC Aps
B=F8gesvinget 8
2740 Skovlunde
44 53 93 66
