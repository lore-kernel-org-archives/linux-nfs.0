From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [NFS] Re: [PATCH] NFS using CacheFS
Date: Tue, 05 Oct 2004 01:10:02 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096931401.22446.157.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C611302B07E52@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	Linux filesystem caching discussion list
	<linux-cachefs@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268674AbUJDXMe@vger.kernel.org>
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07E52@lavender-fe.eng.netapp.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 ty , 05/10/2004 klokka 00:51, skreiv Lever, Charles:

> probably ought to look like the Solaris UI here.  isn't there a "cach=
efs" mount option on Solaris?  anyway, reusing "posix" just for a proto=
type seems harmless enough.

Mounting Solaris cachefs is very different. Their syntax is of the form=
:

mount -F cachefs [    generic_options     ] -o backfstype=3Dfile_system=
_type   [  specific_options  ]  [ -O ] special mount_point

So an example given on their manpage is as follows:

------
     The  following  example  CacheFS-mounts  the   file   system
     server1:/user2,  which is already NFS-mounted on /usr/abc as
     /xyz.

      example# mount -F cachefs -o backfstype=3Dnfs,backpath=3D/usr/abc=
,
          cachedir=3D/cache1 server1:/user2 /xyz
------

Cheers,
  Trond
