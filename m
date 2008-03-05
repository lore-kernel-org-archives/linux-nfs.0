From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 05 Mar 2008 13:49:47 -0800
Message-ID: <47CF157B.1010908@m2000.com>
References: <47CF0829.4020502@m2000.com> <1204752463.5035.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8F389DC113CFB03FAB0C2D6A"
Cc: lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>, jesper.juhl@gmail.com,
	Neil Brown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from asterix.m2000.com ([212.155.102.83]:3147 "EHLO
	asterix.m2000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbYCEVuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2008 16:50:24 -0500
In-Reply-To: <1204752463.5035.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8F389DC113CFB03FAB0C2D6A
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Trond Myklebust wrote:
> On Wed, 2008-03-05 at 12:52 -0800, Adam Schrotenboer wrote:
>  =20
>> Running SLES 10 on multiple compute nodes, with an OpenSuSE 10.2 NFS
>> server, and I am receiving the above log message on a semi-regular bas=
is
>> in the NFS client system-logs. When this occurs, one of the users
>> receives an error (although there seems to be no way to easily collate=

>> the users experience with the system log, short of using the timestamp=
).
>>      Sometimes it's "read/write error", sometimes it's more specific
>> about something that was a file now being a directory (SVN tends to be=

>> rather more verbose). Most of the time this is just a nuisance, but at=
=20
>> times (such as last week or so) it occurs so often that it blocks any =

>> work getting done.
>>
>>      The NFS Server is running OpenSuSE 10.2 on a Dell PowerEdge 2900 =

>> with the PERC5/i controller. The NFS Clients are all SLES10 with the=20
>> standard mountoptions, and running in TCP mode (something about UDP + =

>> NFS + GbE leads to subtle data corruption).
>>    =20
>
> Could you be a little bit more specific about the nature of the NFS
> server: are you using knfsd or is this the legacy userland server?
> Please also specify what kind of filesystem you are exporting, and the
> export options you are using.
>  =20
We're using the kernel NFSd. The exported FS is XFS.
/mnt/storage0/users=20
192.168.1.6(rw,sync,insecure,no_subtree_check,no_root_squash)=20
192.168.1.0/24(rw,sync,insecure,no_subtree_check)

> As for the client side, when do these errors occur? Have you seen them
> occur after a prolonged period of use, or are they more frequent
> immediately after a reboot or mount operation?
>  =20
They occur mostly randomly, we have not noticed any particular pattern=20
to their occurrence, we have not noticed any correlation with mount-time.=

Here is an excerpt from one of our servers. Note that all servers were=20
shutdown on Feb 29th and restarted on March 1st due to a planned power=20
outage. All systems are backed up by UPS.
> Cheers
>   Trond
>  =20



--------------enig8F389DC113CFB03FAB0C2D6A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHzxV7yWYDdvnGArwRAkCAAKC4eRlBbe8+coF9JYp8ZB2sDMBoVQCgn+St
zyVoIU4bHq06IipT8hkwuJs=
=rEqP
-----END PGP SIGNATURE-----

--------------enig8F389DC113CFB03FAB0C2D6A--
