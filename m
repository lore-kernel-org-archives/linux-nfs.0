From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Questiong regarding change in support for > 256 outstanding read/write operations per mount point for linux clients
Date: Wed, 9 Jun 2004 07:08:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07CB9@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C44E2B.3E3CD852"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY3kz-0005Ne-Qi
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 07:08:45 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BY3kz-0003lK-6w
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 07:08:45 -0700
To: <work-usenet@nouce.net>
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

This is a multi-part message in MIME format.

------_=_NextPart_001_01C44E2B.3E3CD852
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

it's pretty simple to boost the 256 page limit by changing the #define
constant right at the top of nfs_flushd.h.

but backporting is an architectural change and requires particular
kernel features which may not exist, or don't have the same
functionality in 2.4, thus it would be difficult to backport (yes, i've
tried).

there are also political issues:  marcelo & trond are not taking any
significant changes for the stock 2.4 code base any longer.  RH will not
take any changes that may break their ABI compatibility.  so the change
would almost certainly be a source code patch and would not likely be
supported by anyone.

finally, there are other limits and bugs in 2.4 that your customers may
be hitting instead.  one example is the limit on the size of the RPC
slot table.

if there is a performance issue with our filers, consider having the
customers open a case with netapp so that we can engage our NFS and
Linux client expertise to help.

> -----Original Message-----
> From: work-usenet@nouce.net [mailto:work-usenet@nouce.net]=20
> Sent: Wednesday, June 09, 2004 9:11 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Questiong regarding change in support for >=20
> 256 outstanding read/write operations per mount point for=20
> linux clients
>=20
>=20
> *Is there a backpatch to allow this change in a 2.4 kernel and/or has=20
> this been added to the 2.6 client? As I use NFS on 2.4 based Linux=20
> systems. But would like to see if this client change would help=20
> performance problems I'm seeing with clients connecting to an Netapp=20
> filer. Thanks.
>=20
>=20
>=20
> B7. I have achieved pretty fast speeds in some client benchmarks, but=20
> when my client is heavily loaded, it slows down considerably.=20
> Why does=20
> that happen? *
>=20
>     *A.* The Linux client limits the total number of pending read or
>     write operations per mount point. This prevents the client from
>     exhausting its memory with cached read or write requests when the
>     network or server is slow. The hard limit is 256=20
> outstanding read or
>     write operations per mount point. When that limit is reached, the
>     client does not issue a new read or write operation until at least
>     one outstanding read or write operation completes, thus=20
> serializing
>     all reads and writes on that mount point until load is reduced.
>=20
>     Two ways of mitigating this effect are to:
>=20
>        1.
>=20
>           Increase rsize and wsize on your client's mount points. This
>           increases the amount of data that can be involved in
>           outstanding reads or writes at any given time.
>=20
>        2.
>=20
>           Mount the same server partition multiple times on your
>           clients, and spread your applications among the=20
> mount points.
>=20
>     This limit has been removed in the 2.5 NFS client (after 2.5.47).
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: GNOME Foundation
> Hackers Unite!  GUADEC: The world's #1 Open Source Desktop=20
> Event. GNOME Users and Developers European Conference,=20
> 28-30th June in Norway http://2004/guadec.org=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20

------_=_NextPart_001_01C44E2B.3E3CD852
Content-Type: application/ms-tnef;
	name="winmail.dat"
Content-Transfer-Encoding: base64

eJ8+IigOAQaQCAAEAAAAAAABAAEAAQeQBgAIAAAA5AQAAAAAAADoAAEIgAcAGAAAAElQTS5NaWNy
b3NvZnQgTWFpbC5Ob3RlADEIAQ2ABAACAAAAAgACAAEEgAEAfgAAAFJFOiBbTkZTXSBRdWVzdGlv
bmcgcmVnYXJkaW5nIGNoYW5nZSBpbiBzdXBwb3J0IGZvciA+IDI1NiBvdXRzdGFuZGluZyByZWFk
L3dyaXRlIG9wZXJhdGlvbnMgcGVyIG1vdW50IHBvaW50IGZvciBsaW51eCBjbGllbnRzAJUtAQWA
AwAOAAAA1AcGAAkABwAIAB4AAwAaAQEggAMADgAAANQHBgAJAAcACAAnAAMAIwEBCYABACEAAABG
NTM5QTA3MjhDNTg1MjQ0QTE5NjJEN0U5NDFBQUFENwAnBwEDkAYAfA8AADQAAAALAAIAAQAAAAMA
JgAAAAAAAwAuAAAAAAADADYAAAAAAEAAOQBS2Dw+K07EAR4APQABAAAABQAAAFJFOiAAAAAAAgFH
AAEAAAAvAAAAYz1VUzthPSA7cD1OVEFQO2w9TEFWRU5ERVItMDQwNjA5MTQwODMwWi02MTUwNAAA
HgBwAAEAAAB6AAAAW05GU10gUXVlc3Rpb25nIHJlZ2FyZGluZyBjaGFuZ2UgaW4gc3VwcG9ydCBm
b3IgPiAyNTYgb3V0c3RhbmRpbmcgcmVhZC93cml0ZSBvcGVyYXRpb25zIHBlciBtb3VudCBwb2lu
dCBmb3IgbGludXggY2xpZW50cwAAAAIBcQABAAAAGwAAAAHETiPQ9R9B/sHCfkxcsRmMJczYZC0A
AYjtoAAeABoMAQAAAA8AAABMZXZlciwgQ2hhcmxlcwAAHgAdDgEAAAB6AAAAW05GU10gUXVlc3Rp
b25nIHJlZ2FyZGluZyBjaGFuZ2UgaW4gc3VwcG9ydCBmb3IgPiAyNTYgb3V0c3RhbmRpbmcgcmVh
ZC93cml0ZSBvcGVyYXRpb25zIHBlciBtb3VudCBwb2ludCBmb3IgbGludXggY2xpZW50cwAAAAIB
CRABAAAAdQgAAHEIAAAkDwAATFpGdeXd7DsDAAoAcmNwZzEyNeIyA0N0ZXgFQQEDAff/CoACpAPk
BxMCgA/zAFAEVj8IVQeyESUOUQMBAgBjaOEKwHNldDIGAAbDESX2MwRGE7cwEiwRMwjvCfe2Oxgf
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
x+POZHdz4lNGLoPRKsB/X7KjYyVAAIAFsESTNFBH8E5PTUVd0G4hyFEtAW1bRkglEUoiVQMADrAh
gTRgR1VBREVDNFCvlGJgIS7AHREjZDBPVWJqU0GURAeQayLCW0ZF95tyOlDnhFWjAUgE7DAr8PcX
sFFBBCBFCHBVUQORCFAfIzAygVHBKyBq9zgtM+4wUoFjIy2RTgWwvGErwCECQHA6Ly9jsi9nsnWO
QWMuZkFhh1/0j3/1n/ZqW0ZYcl+yZXI0YC3/NGBYcWVvX0RbRvKSNEDy4D/5T19S+5T7kwuAAhAv
bguEoXBdff8wAAAAHgA1EAEAAABGAAAAPDQ4MkEzRkEwMDUwRDIxNDE5QzI2OUQxMzk4OUM2MTEz
MDJCMDdDQjlAbGF2ZW5kZXItZmUuZW5nLm5ldGFwcC5jb20+AAAAHgBCEAEAAAAdAAAAPDQwQzcw
QzUwLjcwMzAxMDVAbm91Y2UubmV0PgAAAAADAIAQ/////wMAkhABAAAACwDyEAEAAAAfAPMQAQAA
AAwBAABSAEUAJQAzAEEAIABbAE4ARgBTAF0AIABRAHUAZQBzAHQAaQBvAG4AZwAgAHIAZQBnAGEA
cgBkAGkAbgBnACAAYwBoAGEAbgBnAGUAIABpAG4AIABzAHUAcABwAG8AcgB0ACAAZgBvAHIAIAAl
ADMARQAgADIANQA2ACAAbwB1AHQAcwB0AGEAbgBkAGkAbgBnACAAcgBlAGEAZAD/+HcAcgBpAHQA
ZQAgAG8AcABlAHIAYQB0AGkAbwBuAHMAIABwAGUAcgAgAG0AbwB1AG4AdAAgAHAAbwBpAG4AdAAg
AGYAbwByACAAbABpAG4AdQB4ACAAYwBsAGkAZQBuAHQAcwAuAEUATQBMAAAACwD2EAAAAABAAAcw
fNv+PStOxAFAAAgwTi4zQytOxAEDAN4/n04AAAMA8T8JBAAAHgD4PwEAAAAPAAAATGV2ZXIsIENo
YXJsZXMAAAIB+T8BAAAASAAAAAAAAADcp0DIwEIQGrS5CAArL+GCAQAAAAAAAAAvTz1OVEFQL09V
PUVOR0lORUVSSU5HL0NOPVJFQ0lQSUVOVFMvQ049Q0VMAB4A+j8BAAAAFQAAAFN5c3RlbSBBZG1p
bmlzdHJhdG9yAAAAAAIB+z8BAAAAHgAAAAAAAADcp0DIwEIQGrS5CAArL+GCAQAAAAAAAAAuAAAA
AwD9P+QEAAADABlAAAAAAAMAGkAAAAAAHgAwQAEAAAAEAAAAQ0VMAB4AMUABAAAABAAAAENFTAAe
ADhAAQAAAAQAAABDRUwAHgA5QAEAAAACAAAALgAAAAMACVkBAAAACwBmgQggBgAAAAAAwAAAAAAA
AEYAAAAADoUAAAAAAAADAH6BCCAGAAAAAADAAAAAAAAARgAAAABShQAAoJgBAB4Af4EIIAYAAAAA
AMAAAAAAAABGAAAAAFSFAAABAAAABQAAADEwLjAAAAAAAwDCgQggBgAAAAAAwAAAAAAAAEYAAAAA
AYUAAAAAAAALAMeBCCAGAAAAAADAAAAAAAAARgAAAAADhQAAAAAAAAMA0YEIIAYAAAAAAMAAAAAA
AABGAAAAABCFAAAAAAAAAwDYgQggBgAAAAAAwAAAAAAAAEYAAAAAGIUAAAAAAAALAEmCCCAGAAAA
AADAAAAAAAAARgAAAAAGhQAAAAAAAAsASoIIIAYAAAAAAMAAAAAAAABGAAAAAIKFAAAAAAAACwAp
AAAAAAALACMAAAAAAAMABhBQFxAYAwAHEHMJAAADABAQAAAAAAMAERABAAAAHgAIEAEAAABlAAAA
SVRTUFJFVFRZU0lNUExFVE9CT09TVFRIRTI1NlBBR0VMSU1JVEJZQ0hBTkdJTkdUSEUjREVGSU5F
Q09OU1RBTlRSSUdIVEFUVEhFVE9QT0ZORlNGTFVTSERIQlVUQkFDS1BPUgAAAAACAX8AAQAAAEYA
AAA8NDgyQTNGQTAwNTBEMjE0MTlDMjY5RDEzOTg5QzYxMTMwMkIwN0NCOUBsYXZlbmRlci1mZS5l
bmcubmV0YXBwLmNvbT4AAAA2gQ==

------_=_NextPart_001_01C44E2B.3E3CD852--


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
