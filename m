Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:41292 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754392AbeBGQSb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 11:18:31 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v4 0/5] NFS basic junction support for nfs-utils
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <878tc5nwgf.fsf@notabene.neil.brown.name>
Date: Wed, 7 Feb 2018 11:17:11 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <16AAEEA5-EFD4-43C4-B5A6-ADA304C5CA5F@oracle.com>
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
 <878tc5nwgf.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 7, 2018, at 1:30 AM, NeilBrown <neilb@suse.com> wrote:
>=20
> On Mon, Jan 29 2018, Chuck Lever wrote:
>=20
>> Still UNTESTED.
>>=20
>> A while back I announced the deprecation of fedfs-utils. There were
>> a handful of components in fedfs-utils that we decided to keep. One
>> of those keepers was the "nfsref" command. (The other was autofs
>> support for /nfs4, which I hope Ian Kent is making progress on ;-)
>>=20
>> This series introduces "nfsref" to nfs-utils, minus the overhead of
>> the LDAP / FedFS machinery, and it builds support for NFS basic
>> junctions into mountd, replacing the need to install a plug-in DLL
>> from fedfs-utils.
>>=20
>> I didn't apply a lot of brain cells to this port, so it's perhaps a
>> little larger than it needs to be. Still, it achieves a completely
>> LDAP-free implementation that resides 100% in nfs-utils. I'm
>> interested in comments about the approach before I do more testing
>> and refinement.
>=20
> It looks sensible to me, though I must confess that I haven't given =
much
> thought to the use of junctions, and have never tried working with =
them.
>=20
> If I understand correctly, you can already do junctions by putting
> archane magic in /etc/exports, and possibly performing
>  mount --bind /foo /foo
> With the patch to mountd, you can put the archane magic in an
> xattr on the directory, and skip the --bind mount.
> Then "nfsref" is a funky tool which adds/lists/removes the archane =
magic
> in a human-readable fashion.
>=20
> That sounds like a generally sensible idea.

Yes, we would like to make the Linux server's implementation of
NFSv4 referrals a little less "black magic," and a little more
"sane administrative interface."


> There seems to be rather
> more code than I would expect for that functionality, but you've =
already
> admitted that, so no surprise there.

This code had to support at least two types of junctions: NFS
basic, and FedFS. That's why the junction extended attributes
contain XML. Though we're not carrying support for FedFS junctions
forward, parsing that XML appears to be the bulkiest part of
this port.


> I was rather surprised to see an rpcgen generated file without the .x.
> I think I understand why that is, and that is one place that you will
> probably remove a lot of unnecessary content, including the comment
> about rpcgen.

Thinking about it, the fedfs_admin.h file is probably needed only
for its definitions of the FEDFS_ERR status codes, which are used
throughout the internal APIs in libjunction. We're certainly not
including an implementation of the FedFS ADMIN protocol.

As a first step I could copy just those to the other new header
file, and that could allow me to get rid of fedfs_admin.h all
together.


> So:  +1

Thanks, Neil!


>=20
> Thanks,
> NeilBrown
>=20
>=20
>>=20
>> ./configure --enable-junction --enable-caps
>>=20
>> is needed before building.
>>=20
>>=20
>> Changes since v3:
>> Broke up the first patch because it was apparently too large to
>> be reflected through vger.kernel.org.
>>=20
>>=20
>> Changes since v2:
>> None.
>>=20
>>=20
>> Changes since RFC (v1):
>> Patch 2/3 in the original series added the libnfsjunct.so DLL to
>> nfs-utils. Series v2 instead replaces 2/3 with a patch that puts
>> support for junctions into mountd without the need for a DLL.
>>=20
>> ---
>>=20
>> Chuck Lever (5):
>>      Add headers to support libjunction
>>      Add infrastructure for libjunction
>>      Add LDAP-free version of libjunction to nfs-utils
>>      mountd: Solder in support for NFS basic junctions
>>      Add LDAP-free 'nfsref' command
>>=20
>>=20
>> aclocal/libxml2.m4                   |   15=20
>> configure.ac                         |   17=20
>> support/Makefile.am                  |    4=20
>> support/include/Makefile.am          |    2=20
>> support/include/fedfs_admin.h        |  342 +++++++
>> support/include/junction.h           |  125 +++
>> support/junction/Makefile.am         |   34 +
>> support/junction/display.c           |  159 +++
>> support/junction/export-cache.c      |  118 +++
>> support/junction/junction-internal.h |  121 +++
>> support/junction/junction.c          |  494 +++++++++++
>> support/junction/locations.c         |  131 +++
>> support/junction/nfs.c               | 1564 =
++++++++++++++++++++++++++++++++++
>> support/junction/path.c              |  345 ++++++++
>> support/junction/xml.c               |  401 +++++++++
>> utils/Makefile.am                    |    4=20
>> utils/mountd/Makefile.am             |    8=20
>> utils/mountd/cache.c                 |  189 ++--
>> utils/nfsref/Makefile.am             |   39 +
>> utils/nfsref/add.c                   |  271 ++++++
>> utils/nfsref/lookup.c                |  211 +++++
>> utils/nfsref/nfsref.c                |  188 ++++
>> utils/nfsref/nfsref.h                |   47 +
>> utils/nfsref/nfsref.man              |  180 ++++
>> utils/nfsref/remove.c                |  145 +++
>> 25 files changed, 5050 insertions(+), 104 deletions(-)
>> create mode 100644 aclocal/libxml2.m4
>> create mode 100644 support/include/fedfs_admin.h
>> create mode 100644 support/include/junction.h
>> create mode 100644 support/junction/Makefile.am
>> create mode 100644 support/junction/display.c
>> create mode 100644 support/junction/export-cache.c
>> create mode 100644 support/junction/junction-internal.h
>> create mode 100644 support/junction/junction.c
>> create mode 100644 support/junction/locations.c
>> create mode 100644 support/junction/nfs.c
>> create mode 100644 support/junction/path.c
>> create mode 100644 support/junction/xml.c
>> create mode 100644 utils/nfsref/Makefile.am
>> create mode 100644 utils/nfsref/add.c
>> create mode 100644 utils/nfsref/lookup.c
>> create mode 100644 utils/nfsref/nfsref.c
>> create mode 100644 utils/nfsref/nfsref.h
>> create mode 100644 utils/nfsref/nfsref.man
>> create mode 100644 utils/nfsref/remove.c
>>=20
>> --
>> Chuck Lever
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



