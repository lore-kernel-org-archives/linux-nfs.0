From: Thomas Lenherr <thomas@lenherr.name>
Subject: Re: nfs corrupts files
Date: Mon, 18 Oct 2004 17:30:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4173E19E.2030409@lenherr.name>
References: <416EA5F4.5090701@lenherr.name> <1097774783.18925.10.camel@lade.trondhjem.org> <416EDA5E.4020000@lenherr.name>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig827B1F23F9D60D42DADFCC89"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJZTQ-0008Og-DF
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 08:31:00 -0700
Received: from mx7.bluewin.ch ([195.186.1.211])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CJZTP-0000IZ-CT
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 08:31:00 -0700
Received: from mephisto.lenherr.name (62.203.240.204) by mx7.bluewin.ch (Bluewin AG 7.0.030.2)
        id 4164054500445302 for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 15:30:51 +0000
Received: from [10.0.0.10] (baal.lenherr.name [10.0.0.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mephisto.lenherr.name (Postfix) with ESMTP id 208481DE24
	for <nfs@lists.sourceforge.net>; Mon, 18 Oct 2004 17:30:50 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <416EDA5E.4020000@lenherr.name>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig827B1F23F9D60D42DADFCC89
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: Quoted-Printable


it's me again...
is there really nobody who might help me? i just don't know what else i=20
should try....
here for short again the problem and what i tried to solve it:
ok: i had 9 big files (each ~180mB) on an nfsv3-server, and they got=20
corrupt when i copied
them down (of course not only these files, but of the files on the=20
nfs-server).
(copied the files via smb for testing, they got not corrupted)
i tried all of the following to solve it:
- updated the kernel of the server and workstation to vanilla 2.6.8.1
- tried nfsv2
- tried nfsv4
- tried nfs over tcp
- had ethereal checking the checksums of all transferred packets via udp=20
while copying one file, all sums were ok
- copied the files _on_the_server_ on an other drive (which is connected=20
to an other (p)ata-controller )

it might be i forgot some of the things i tried, but this list should=20
contain most of it...

btw: is there some kind of a verbose-flag to toggle so i might get some=20
more log-entries about nfs?
right now i don't get any entry, neither on the server, nor on the=20
client, so it's somehow like nfs
reads wrong data from the drives and builds all the checksums after this=20
so error is detected....

please somebody help me, i don't want switch to samba giving lousy 4mB/s=20
transfer-speed instead
of the 11mB/s of nfs... :(

thanks anyway....

 thomas


Thomas Lenherr wrote:

> sorry, for forgetting the kernel of the workstation, it's yet another=20
> gentoo-kernel: 2.6.7-gentoo-r6.
> i looked up the difference between the vanilla kernel 2.6.7 and this=20
> patched gentoo-version
> and it seems it's not really much, just stuff like bootsplash, console=20
> speakup and something
> about making it ready for supermount...
>
> anyway, as you said i installed the original 2.6.8.1 on the server and=20
> tried the whole
> thing again, what means i copied the 9 files over nfs and let them=20
> check with md5sum.
> same result :(
>
> i did not yet update the kernel of the workstation, because i accessed=20
> the nfs server
> with an windows-implementation of nfs and experienced the same=20
> troubles. so i think
> the server is the faulty one...
>
> cheers,
> thomas
>
>
>
> Trond Myklebust wrote:
>
>> P=E5 to , 14/10/2004 klokka 18:14, skreiv Thomas Lenherr:
>>
>> =20
>>
>>> ok, here is what i did:
>>> i had some files on an nfs-server (v3) using kernel 2.6.8-gentoo-r8
>>> (updated because of the trouble). the 9 files had an average size of
>>> about 180mB and i built the md5sums of these files via ssh _on_ this
>>> server.
>>>
>>> after that i transferred these files to my workstation, once via nfs=20
>>> and
>>> once via smb and let them check with md5sum again. the files=20
>>> transferred
>>> with smb were ok, but 6 of the 9 files tranferred via nfs were corrup=
t.
>>> then i made cmp between the local files (transferred with nfs of=20
>>> course)
>>> and the files on the nfs-server. the result:
>>> 1) multiple use of cmp on files which md5sum mentioned as corrupt
>>> resulted in reporting differences at different positions
>>> 2) sometimes the usage of cmp on files which md5sum mentioned as=20
>>> correct
>>> resulted in reporting differences...
>>>  =20
>>
>>
>> You don't mention which kernel the client was running. Was it the same
>> as the server?
>>
>> Have you tried just grabbing a kernel 2.6.8.1 from ftp.kernel.org, and
>> compiling it up (using the same .config as the gentoo kernel if you
>> like) and then doing the same thing? I ask 'cos I just don't know what
>> is in the gentoo kernels.
>>
>> Cheers,
>>  Trond
>>
>>
>>
>> -------------------------------------------------------
>> This SF.net email is sponsored by: IT Product Guide on ITManagersJourn=
al
>> Use IT products in your business? Tell us what you think of them.=20
>> Give us
>> Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find=20
>> out more
>> http://productguide.itmanagersjournal.com/guidepromo.tmpl
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>> =20
>>

--------------enig827B1F23F9D60D42DADFCC89
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBc+Go3E1pPHX30VoRAiZ6AJ0daKX5qbv6lxUqcUSbKbJ5bL2/XQCgijZq
YBVHqOF5LFPwplmEUoFzeEo=
=PIdA
-----END PGP SIGNATURE-----

--------------enig827B1F23F9D60D42DADFCC89--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
