From: "Lever, Charles" <cel@netapp.com>
Subject: RE: [NFS] Re: [PATCH] NFS using CacheFS
Date: Mon, 4 Oct 2004 15:51:57 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <482A3FA0050D21419C269D13989C611302B07E52@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>,
	"Linux filesystem caching discussion list" <linux-cachefs@redhat.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268665AbUJDWwa@vger.kernel.org>
To: "Steve Dickson" <SteveD@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

> P=E5 m=E5 , 04/10/2004 klokka 22:45, skreiv Steve Dickson:
>=20
> > 3) There is no user level support. I realize this is=20
> extremely cheesy
> >      but I noticed that the NFS posix mount  option (in the=20
> 2.6 kernel)
> >      was no longer being used, so I high jacked it.  Which means
> >      to make NFS to used CacheFS you need to use the posix option:
> >=20
> >      mount -o posix server:/export/home /mnt/server/home
>=20
> This is my one and only real gripe about it. The posix mount option i=
s
> clearly documented, so we really cannot play around with it. Why can'=
t
> you just add a separate cachefs flag?

probably ought to look like the Solaris UI here.  isn't there a "cachef=
s" mount option on Solaris?  anyway, reusing "posix" just for a prototy=
pe seems harmless enough.

> I'm a bit worried about the use of the raw IP address in
> nfs_cache_server_match(). It seems to me that when we add the NFSv4.1
> support for trunking over several different transport mechanisms (RDM=
A,
> IPv4/v6 etc) on the same mountpoint, then we may end up with a proble=
m.
> We can probably leave it in for now, but later we may want to conside=
r
> switching to using server->hostname or something equivalent.

yup, we want to avoid adding any transport specific detail in the NFS c=
lient, and leave that kind of stuff to the RPC client.  good catch, tro=
nd.

i did a lengthy study of the AFS cache manager about a decade ago.  int=
erestingly, the place where it really falls down is in recycling disk b=
locks for use with a new incoming file to be cached.  the underlying ca=
che file system has to get rid of the on-disk data for old files before=
 it can reuse the blocks for a new file.  otherwise, the old data is ex=
posed if the new file maps in pages it hasn't written to yet.  if the c=
ache is turning over quickly, handling this correctly can result in ser=
ious disk thrashing as the cache file system frees and erases blocks on=
 disk and then reallocates them to the new file.

steve, is there [english] documentation somewhere that describes how th=
e cachefs works?
