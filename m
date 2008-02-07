From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: kernel exports table flushes out on running exportfs -a over mips
Date: Wed, 6 Feb 2008 18:19:36 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C57984DC@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C5743B89@exchange.ZeugmaSystems.local> <20080131023654.GA45273388@ocelot.melbourne.sgi.com> <DDFD17CC94A9BD49A82147DDF7D545C5743D74@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C8692F.FDDA9724"
Cc: <linux-nfs@vger.kernel.org>
To: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>,
	"Greg Banks" <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:16442 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757934AbYBGCUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 21:20:23 -0500
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C5743D74-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8692F.FDDA9724
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi:

I did some extensive digging into the codebase and I believe I have the
reason
why exportfs -a flushes out the caches after NFS clients have mounted
the NFS filesystem.=20
The analysis is complicated, but here's
the crux of the matter:=20

There is a difference in the /etc/exports and the kernel maintained
cache. The
difference is that in /etc/exports, we use anonymous clients (*) whereas
kernel
maintains a FQDN client names in its exports cache (see attached file).
This
difference (the parsing code client_gettype() specifically checks for a
* or an IP or hostname among other things and based on that creates two
different types of caches) is causing the nfs codebase to recreate new
in core exports entries (the second time when we issue "exportfs -a")
after parsing /proc/fs/nfs/export. Immediately later, it then throws
these away (for these
newly created entries, m_mayexport =3D 0 and m_exported =3D 1 in =
function
xtab_read()). For details, see the logic in exports_update_one():

if (exp->m_exported && !exp->m_mayexport) { ... unexporting ...}


Since both the anonymous and FQDN entries are essentially the same, this
results in blowing away the existing kernel exports table.=20

My question is, is there a elegant solution to this problem without
simply using FQDN in /etc/exports? I have confirmed that the problem
does not occur when both the in kernel and /etc/exports tables have same
entries (both * or both FQDN).

Cheers,

Ani


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Anirban Sinha
> Sent: Thursday, January 31, 2008 2:09 PM
> To: Greg Banks
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: kernel exports table flushes out on running exportfs -a
> over mips
>=20
> Hi Greg:
>=20
> Thanks for replying. Here goes my response:
>=20
> > -----Original Message-----
> > From: Greg Banks [mailto:gnb@sgi.com]
> > Sent: Wednesday, January 30, 2008 6:37 PM
> > To: Anirban Sinha
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: kernel exports table flushes out on running exportfs -a
> > over mips
> >
> > On Wed, Jan 30, 2008 at 05:34:13PM -0800, Anirban Sinha wrote:
> > > Hi:
> > >
> > > I am seeing an unusual problem on running nfs server on mips. Over
> > Intel
> > > this does not happen. When I run exportfs -a on the server when
the
> > > clients have already mounted their nfs filesystem, the kernel
> exports
> > > table as can be seen from /proc/fs/nfs/exports gets completely
> > flushed
> > > out. We (me and one another colleague) have done some digging
> (mostly
> > > looking into nfsutils codebase) and it looks like a kernel side
> > issue.
> > > We had also asked folks in the linux-mips mailing list, but
> > apparently
> > > no one has any clue. I am just hoping that those who are more
> > familiar
> > > with the user level and kernel side of nfs might me something more
> to
> > > chew on. If you can give any suggestions that will be really
> useful.
> > If
> > > you think the information I provided is not enough, I can give you
> > any
> > > other information you need in this regard.
> >
> > Does the MIPS box have the /proc/fs/nfsd/ filesystem mounted?
>=20
> Ahh, I see what you mean. Yes, it is mounted, both /proc/fs/nfsd and
> /proc/fs/nfs. However, I can see from the code that check_new_cache()
> checks for a file "filehandle" which does not exist in that location.
> To be dead sure, I instrumented the code to insert a perror and it
> returns "no such file or directory". The new_cache flag remains 0. Is
> this some sort of kernel bug?
>=20
>=20
> > Perhaps you could try
> >
> > 1) running exportfs under strace.  I suggest
> >    strace -o /tmp/s.log -s 1024 exportfs ...
>=20
> Strace does not work in our environment as it has not been properly
> ported to mips.
>=20
> > 2) AND enabling kernel debug messages
> >    rpcdebug -m nfsd -s export
> >    rpcdebug -m rpc -s cache
>=20
> I attach the dmesg output after enabling those flags. Zeugma-x-y are
> the clients to this server. Not sure if it means anything suspicious.
>=20
> Ani
>=20
>=20
> >
> >
> > --
> > Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> > The cake is *not* a lie.
> > I don't speak for SGI.

------_=_NextPart_001_01C8692F.FDDA9724
Content-Type: text/plain;
	name="exports_tables.txt"
Content-Transfer-Encoding: base64
Content-Description: exports_tables.txt
Content-Disposition: attachment;
	filename="exports_tables.txt"

cm9vdDoxQDEuWmV1Z21hOn4jIGNhdCAvcHJvYy9mcy9uZnMvZXhwb3J0cwojIFZlcnNpb24gMS4x
CiMgUGF0aCBDbGllbnQoRmxhZ3MpICMgSVBzCi9jZjQgICAgemV1Z21hLTEtMyhydyxpbnNlY3Vy
ZSxub19yb290X3NxdWFzaCxhc3luYyx3ZGVsYXksbm9fc3VidHJlZV9jaGVjayxpbnNlY3VyZV9s
b2NrcykKL2NmMiAgICB6ZXVnbWEtMS00KHJ3LGluc2VjdXJlLG5vX3Jvb3Rfc3F1YXNoLGFzeW5j
LHdkZWxheSxub19zdWJ0cmVlX2NoZWNrLGluc2VjdXJlX2xvY2tzKQovY2YyL2NwdTMgICAgICAg
emV1Z21hLTEtMyhydyxpbnNlY3VyZSxub19yb290X3NxdWFzaCxhc3luYyx3ZGVsYXksbm9fc3Vi
dHJlZV9jaGVjayxpbnNlY3VyZV9sb2NrcykKL2NmMi9jcHU0ICAgICAgIHpldWdtYS0xLTQocncs
aW5zZWN1cmUsbm9fcm9vdF9zcXVhc2gsYXN5bmMsd2RlbGF5LG5vX3N1YnRyZWVfY2hlY2ssaW5z
ZWN1cmVfbG9ja3MpCi9jZjIvY3B1MiAgICAgICB6ZXVnbWEtMS0yKHJ3LGluc2VjdXJlLG5vX3Jv
b3Rfc3F1YXNoLGFzeW5jLHdkZWxheSxub19zdWJ0cmVlX2NoZWNrLGluc2VjdXJlX2xvY2tzKQov
Y2YyICAgIHpldWdtYS0xLTIocncsaW5zZWN1cmUsbm9fcm9vdF9zcXVhc2gsYXN5bmMsd2RlbGF5
LG5vX3N1YnRyZWVfY2hlY2ssaW5zZWN1cmVfbG9ja3MpCi9jZjQgICAgemV1Z21hLTEtMihydyxp
bnNlY3VyZSxub19yb290X3NxdWFzaCxhc3luYyx3ZGVsYXksbm9fc3VidHJlZV9jaGVjayxpbnNl
Y3VyZV9sb2NrcykKL2NmNCAgICB6ZXVnbWEtMS00KHJ3LGluc2VjdXJlLG5vX3Jvb3Rfc3F1YXNo
LGFzeW5jLHdkZWxheSxub19zdWJ0cmVlX2NoZWNrLGluc2VjdXJlX2xvY2tzKQovY2YyICAgIHpl
dWdtYS0xLTMocncsaW5zZWN1cmUsbm9fcm9vdF9zcXVhc2gsYXN5bmMsd2RlbGF5LG5vX3N1YnRy
ZWVfY2hlY2ssaW5zZWN1cmVfbG9ja3MpCgpyb290OjFAMS5aZXVnbWE6fiMgY2F0IC9ldGMvZXhw
b3J0cwovY2YyICAgICAgICAgICAgICoocncsaW5zZWN1cmUsYXN5bmMsaW5zZWN1cmVfbG9ja3Ms
bm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2NmMi9jcHUyICAgICAgICAqKHJ3LGlu
c2VjdXJlLGFzeW5jLGluc2VjdXJlX2xvY2tzLG5vX3N1YnRyZWVfY2hlY2ssbm9fcm9vdF9zcXVh
c2gpCi9jZjIvY3B1MyAgICAgICAgKihydyxpbnNlY3VyZSxhc3luYyxpbnNlY3VyZV9sb2Nrcyxu
b19zdWJ0cmVlX2NoZWNrLG5vX3Jvb3Rfc3F1YXNoKQovY2YyL2NwdTQgICAgICAgICoocncsaW5z
ZWN1cmUsYXN5bmMsaW5zZWN1cmVfbG9ja3Msbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFz
aCkKL2NmNCAgICAgICAgICAgICAqKHJ3LGluc2VjdXJlLGFzeW5jLGluc2VjdXJlX2xvY2tzLG5v
X3N1YnRyZWVfY2hlY2ssbm9fcm9vdF9zcXVhc2gpCg==

------_=_NextPart_001_01C8692F.FDDA9724--
