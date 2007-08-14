From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Tue, 14 Aug 2007 08:58:41 -0400
Message-ID: <20070814085841.320c1b98.jlayton@redhat.com>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<1187021560.6628.7.camel@heimdal.trondhjem.org>
	<1187022103.6628.12.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
	<1187024268.6628.33.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131939160.20652@maggie.lkpg.cendio.se>
	<1187033724.6628.82.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708140923370.3964@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKvz2-0001qU-Jd
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 05:58:53 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKvz6-0005zU-I0
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 05:58:56 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7ECwk49006403
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 08:58:46 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7ECwkIE023740
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 08:58:46 -0400
Received: from tupile.connectathon.org (vpn-14-153.rdu.redhat.com
	[10.11.14.153])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l7ECwjx7023380
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 08:58:45 -0400
In-Reply-To: <Pine.LNX.4.64.0708140923370.3964@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 14 Aug 2007 09:58:41 +0200 (CEST)
Peter =C5strand <astrand@cendio.se> wrote:

> On Mon, 13 Aug 2007, Trond Myklebust wrote:
> =

> > > > If it isn't capable of dealing with the possibility of EOVERFLOW, t=
hen
> > > > it is violating the Single Unix Spec.
> > > =

> > > What can an app do, besides displaying a good error message? There's =
no =

> > > way to "deal" with EOVERFLOW that makes the user happy. =

> > =

> > So you are saying it should never have been defined in the first place?
> =

> No, it might be useful from time to time, on some systems. =

> =

> For example, the previous situation was that you got EOVERFLOW on 64 bit =

> kernels but truncated inode numbers on 32 bit kernels. I think this was a =

> fairly good compromise - customers had a choice. Typically, you select a =

> 32 bit kernel not because your hardware cannot do 64 bits, but because yo=
u =

> want maximum compatibility with old apps. So the approach with keep =

> truncating on 32 bit kernels made sense. =

> =

> Again, if would be even better if the behaviour could be selected runtime =

> or boot-time. A patch which simply changes this unconditionally is a =

> regression, IMHO.
> =

> =

> > > I can't see how a lack of LFS (of a binary) is a violation of SUS or =

> > > POSIX. Linux Standard Base requires that a platform provides LFS supp=
ort, =

> > > but it doesn't deprecate or forbid the non-LFS API functions.
> > =

> > If you are using the correct types, then recompiling with
> > -D_FILE_OFFSET_BITS=3D64 should be sufficient to enable LFS-compliant
> > behaviour. Portability was the reason for defining those types in the
> > first place.
> =

> You shouldn't be required to recompile. =

> =

> =

> > > Recompiling is almost never trivial. OpenOffice.org is just one examp=
le of =

> > > this. KDE is another. And sometimes the source is not available. =

> > =

> > Recompiling packages like OpenOffice.org is the bread-and-butter
> > business of Linux distributors.
> =

> Still, OO is not recompiled in RHEL5. =

> =

> In my opinion, it's also wrong to assume that all software running on a =

> certain system is compiled by the distribution maker. This is somewhat of =

> a Debian approach: all software should be included in the distribution, o=
r =

> may otherwise fail. Wrong, IMHO. =

> =

> =

> > > I still haven't understood what kind of functionality you are "sick a=
nd =

> > > tired of having to constantly postpone", that requires EOVERFLOW in 3=
2 bit =

> > > non-LFS land. =

> > =

> > The ability to supply the full 64-bit inode numbers to actual LFS
> > compliant applications.
> > LFS-aware backup apps, for instance, still cannot trust the inode number
> > to tell them whether or not two directory entries are actually hard
> > links to the same file. That would be pretty much the entire reason for
> > wanting to look at the st_ino variable in the first place.
> =

> LFS-aware applications running on 32 bit platforms needs to understand =

> that the world is not yet perfect. Even if 2.6.24 would stop truncating, =

> there are hundreds of earlier kernel versions in use, which will probably =

> still be in use for several more years from now. =

> =

> The backup application can take some extra care, for example, by verifyin=
g =

> st_size, st_mtime and perhaps a few bytes of the file as well. Not rocket =

> science. Probably done anyway, to detect if the file has been changed =

> during backup.
> =

> Still, I'm not opposing to enable full 64 bit inode numbers for LFS apps, =

> as long as non-LFS apps can still run. I'm no glibc expert, but as I =

> understand it, it *should* be possible to fix this in glibc. Have you =

> tried talking to the glibc developers about this? =

> =


A while back, I worked on a somewhat related patch to make sure that
the inode numbers generated by new_inode and iunique wouldn't generate
an EOVERFLOW in a non-LFS stat() call. My first proposal was to fix
this in glibc, but Jakub Jelenek disagreed with the approach. His
comments are here:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D213635#c16

comment #15 has a patch to affect this behavior based on an environment
var. I think you'll have a tough time convincing the glibc developers
that it's better to return a bogus st_ino rather than an error here.
Granted, NFS is a bit of a different situation, so maybe you'll have
better luck. =


-- =

Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
