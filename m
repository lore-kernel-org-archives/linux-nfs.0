From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: nfs lock question...
Date: Wed, 25 Jun 2003 09:30:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B384449157@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_000_01C33AEB.B80F0AE8"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes3.atos-group.com ([160.92.18.10])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19V4kE-0003To-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 00:31:06 -0700
To: 'Trond Myklebust' <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C33AEB.B80F0AE8
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Tuesday, June 24, 2003 9:00 PM
> To: Brasseur Val=E9ry
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] nfs lock question...
>=20
>=20
> >>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> =
writes:
>=20
>      > is it normal that when a process is stoppped (ctrl-z ;-) and =
he
>      > has locks on a nfs-server
>=20
> Yes. ctrl-z will normally suspend the process. It does nothing to =
kill
> it...
>=20
>      > if this nfs server reboot the stopped process does'nt reclaim
>      > it's locks ?!!!
>=20
> Why not? That's a separate thread...
>=20
It's what I have seen in my tests !!! but yes i don't understand it !!!


> Cheers,
>   Trond
>=20

------_=_NextPart_000_01C33AEB.B80F0AE8
Content-Type: application/ms-tnef
Content-Transfer-Encoding: base64

eJ8+IjwHAQaQCAAEAAAAAAABAAEAAQeQBgAIAAAA5AQAAAAAAADoAAEIgAcAGAAAAElQTS5NaWNy
b3NvZnQgTWFpbC5Ob3RlADEIAQmAAQAhAAAAQ0U0RDdCQUQ5QzIwMEU0RDhDQUEwMDMwN0E0OTIx
NDgAPQcBIIADAA4AAADTBwYAGQAJAB4AOwADAF4BAQWAAwAOAAAA0wcGABkACQAeADkAAwBcAQEE
gAEAHwAAAFJFOiBbTkZTXSBuZnMgbG9jayBxdWVzdGlvbi4uLgDiCQENgAQAAgAAAAIAAgABA5AG
AFgIAAAzAAAACwACAAEAAAADAC4AAAAAAEAAOQDoCg+46zrDAR4AMUABAAAACgAAAFZCUkFTU0VV
UgAAAAMAGkAAAAAAHgAwQAEAAAAKAAAAVkJSQVNTRVVSAAAAAwAZQAAAAAAeAHAAAQAAABsAAABb
TkZTXSBuZnMgbG9jayBxdWVzdGlvbi4uLgAAAgFxAAEAAAAbAAAAAcM6gsnKTvOcnGiOQ/Wv68yz
btnRLAAaNvIAAAIBCRABAAAA2wIAANcCAAB6BAAATFpGdc/p2AEDAAoAcmNwZzEyNeIyA0N0ZXgF
QQEDAfdPCoACpAPjAgBjaArAc/BldDAgBxMCgA/zAFB/BFYIVQeyEcUOUQMBEMcy9wYABsMRxTME
RhDJEtsR09sI7wn3Oxi/DjA1EcIMYM5jAFALCQFkMzYRUAumUCA+IC0dsk8FEGcPC4AHQAXQB5Bz
YWdlLx2zCqIKgB2QRgNhOiASVANgbmQF0HlrbNBlYnVzBUBbAMADEJB0bzp0IEIubSCmAEBmeXMu
dWlv8C5ub10fVgZgAjAgEQEKUHNkYXksIErAdW5lIDI0JLAB0CAwMyA5OiVwIFAKTR9WVCGQIEJy
YSUEEGUIcCBWB0BcJ5BlOXJ5H1ZDYyAQUm4D0EBsBAB0ItBz/QhhYwEQBbAe4CMgETAjZ5h1YmoF
kCQRUmUgEKBbTkZTXSiyIBhQUGNrIHEkUXQjAG4uLi0QH1YtTj4uwiAimS8RPT0m3yfgIDwncckE
kHkuL5ZAYSGAKWDVHhMuBaBtHZB3BRAOsPxzOi1ONDMdkAQANKAFQG0jMHIAwAMgdBDwBUB3wmgJ
8CBhIHADYCmgZwQRNLEhAG9wNyAJgCACKCsgcmwteiA7/C0pNhAgYTXgM80Q8CwkLwQgAiA2ESjB
LREgcnbLBJAtTlkHkC4gN5UD8NZsAyA1FGwwoHMg8DdAXyBhNYAlADZFPFBJBUBkXm8HkSMwNYAL
gGc1cG98IGs88R9WMvAtHzQoZu81cTSxLAI6xCAYwAbgP6DfPjM28zdRNkY/QicCMEPhSmMLYW0z
znQnObY/ZiFIQC1OV2gwoD+RP/8gIDWRR6E2IBEgCrEx0CUA+zWAGMBhIfBBPj8QR6E10H01oUk5
gTrwQ3E18QuAIN8iEDVwLLEEIEhBICDgBUDKeQeRaT8xbicFQCTg/wSBIQA4QjThSEdRCihhNeBd
UCEsM8ggMy1MfVSQAB4AQhABAAAAIQAAADxzaHNsbHZydGk3My5mc2ZAY2hhcmdlZC51aW8ubm8+
AAAAAAMAJgAAAAAAAwA2AAAAAAADAN4/r28AAAMA8T8MBAAAAwD9P+QEAAADAAlZAQAAAAsABYAI
IAYAAAAAAMAAAAAAAABGAAAAAA6FAAAAAAAAAwABgAggBgAAAAAAwAAAAAAAAEYAAAAAUoUAAHN5
AQAeAAKACCAGAAAAAADAAAAAAAAARgAAAABUhQAAAQAAAAQAAAA5LjAAAwADgAggBgAAAAAAwAAA
AAAAAEYAAAAAAYUAAAAAAAALAASACCAGAAAAAADAAAAAAAAARgAAAAADhQAAAAAAAAMAB4AIIAYA
AAAAAMAAAAAAAABGAAAAABGFAAAAAAAAAwAGgAggBgAAAAAAwAAAAAAAAEYAAAAAEIUAAAAAAAAD
AAiACCAGAAAAAADAAAAAAAAARgAAAAAYhQAAAAAAAAsADIAIIAYAAAAAAMAAAAAAAABGAAAAAAaF
AAAAAAAAAwCAEP////8eAPMQAQAAACUAAABSRSUzQSBbTkZTXSBuZnMgbG9jayBxdWVzdGlvbi4u
Li5FTUwAAAAACwD2EAAAAAALAPQQAAAAAAsA9RAAAAAAAgFHAAEAAAAwAAAAYz1GUjthPSA7cD1B
VE9TO2w9U1JWLUdSUC1TMDctMDMwNjI1MDczMDU3Wi0xODIAAgH5PwEAAABFAAAAAAAAANynQMjA
QhAatLkIACsv4YIBAAAAAAAAAC9PPUFUT1MvT1U9TU0vQ049UkVDSVBJRU5UUy9DTj1WQlJBU1NF
VVIAAAAAHgD4PwEAAAAQAAAAQnJhc3NldXIgVmFs6XJ5AB4AOEABAAAACgAAAFZCUkFTU0VVUgAA
AAIB+z8BAAAARQAAAAAAAADcp0DIwEIQGrS5CAArL+GCAQAAAAAAAAAvTz1BVE9TL09VPU1NL0NO
PVJFQ0lQSUVOVFMvQ049VkJSQVNTRVVSAAAAAB4A+j8BAAAAEAAAAEJyYXNzZXVyIFZhbOlyeQAe
ADlAAQAAAAoAAABWQlJBU1NFVVIAAABAAAcwAEiLpes6wwFAAAgw6nrhuOs6wwEeAD0AAQAAAAUA
AABSRTogAAAAAB4AHQ4BAAAAGwAAAFtORlNdIG5mcyBsb2NrIHF1ZXN0aW9uLi4uAAAeADUQAQAA
AEEAAAA8ODE0N0UxQjA3MjAxREQ0MUI2QjlGMEQzMUUwN0IzODQ0NDkxNTdAc3J2LWdycC1zMDcu
ZGV2LmF0b3MuZnI+AAAAAAsAKQAAAAAACwAjAAAAAAADAAYQzgOOlwMABxD8AQAAAwAQEAEAAAAD
ABEQAQAAAB4ACBABAAAAZQAAAC0tLS0tT1JJR0lOQUxNRVNTQUdFLS0tLS1GUk9NOlRST05ETVlL
TEVCVVNUTUFJTFRPOlRST05ETVlLTEVCVVNUQEZZU1VJT05PU0VOVDpUVUVTREFZLEpVTkUyNCwy
MDAzOToAAAAAAgF/AAEAAABBAAAAPDgxNDdFMUIwNzIwMURENDFCNkI5RjBEMzFFMDdCMzg0NDQ5
MTU3QHNydi1ncnAtczA3LmRldi5hdG9zLmZyPgAAAAAZ6Q==

------_=_NextPart_000_01C33AEB.B80F0AE8--


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
