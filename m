From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: RE: Another hang problem - Jukebox error (was: NFS hangs for15 seconds after exportfs -r)
Date: Thu, 19 Jan 2006 11:23:41 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B0749F0A9@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzdVr-0000eO-HD
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 09:23:55 -0800
Received: from ext-ch1gw-8.online-age.net ([64.37.194.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzdVm-0000oh-U9
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 09:23:55 -0800
Received: from int-ch1gw-3.online-age.net (int-ch1gw-3 [3.159.232.67])
	by ext-ch1gw-8.online-age.net (8.13.4/8.13.5/20051111-SVVS-TLS-DNSBL) with ESMTP id k0JHNhQI025352
	for <nfs@lists.sourceforge.net>; Thu, 19 Jan 2006 12:23:43 -0500
Received: from cinmlef11.e2k.ad.ge.com (localhost [127.0.0.1])
	by int-ch1gw-3.online-age.net (8.12.9/8.12.3/990426-RLH) with ESMTP id k0JHNgud007003
	for <nfs@lists.sourceforge.net>; Thu, 19 Jan 2006 12:23:42 -0500 (EST)
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
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


I have compared the versions and it went in 2.6.9, was still in 2.6.10
and disappeared in 2.6.11.  I have built a custom version of 2.6.9 and
it fails the same as the generic RHEL4/WBEL4 2.6.9 kernel.  I then
built a 2.6.11 kernel and it does NOT exhibit the Jukebox error problem.
I am going to build a 2.6.10 kernel just to confirm that it has the
failure.

This is kind of sticky because I can't really move to later kernels.
The whole purpose of going with a Enterprise version was just to get a
stable kernel version, with security fixes but not other changes.  It's=20
too much trouble to have to move to new kernels just to get security=20
fixes.  The other changes we get keep breaking things (like this ;-).

I am guessing the only thing to do is to make a custom version of 2.6.9
without that Jukebox stuff.  I assume that there is more to removing it
than just deleting the "{ nfserr_jukebox, -EWOULDBLOCK }," line from
nfsproc.c.  I will start comparing the changes.  If anyone can tell me
if there is an easier way to find all the associated changes, please
advise.

Thanks
  -Scott


-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org]
Sent: Wednesday, January 18, 2006 2:55 PM
To: Trond Myklebust
Cc: Edwards, Scott (GE Healthcare); nfs@lists.sourceforge.net
Subject: Re: [NFS] Another hang problem - Jukebox error (was: NFS hangs
for15 seconds after exportfs -r)


On Wed, Jan 18, 2006 at 04:46:09PM -0500, Trond Myklebust wrote:
> On Wed, 2006-01-18 at 15:37 -0600, Edwards, Scott (GE Healthcare) =
wrote:
> > Hi Trond,
> >=20
> > It appears to me that ETIMEDOUT was the only one translated to =
JUKEBOX
> > prior to 2.6.9, but this was added in 2.6.9:
> >=20
> > msa8002@ox$ diff linux-2.6.9/fs/nfsd/nfsproc.c linux-2.6.8.1/fs/nfsd
> > 589d588
> > <               { nfserr_jukebox, -EWOULDBLOCK },
> > msa8002@ox$=20
>=20
> Sure? I checked out the today's GIT tree and all I get is
>=20
> trondmy@lade nfsd$ grep -i jukebox *
> nfs4state.c:                            status =3D nfserr_jukebox;
> nfsproc.c:              { nfserr_jukebox, -ETIMEDOUT },
> nfssvc.c:       if (nfserr =3D=3D nfserr_jukebox && rqstp->rq_vers =
=3D=3D 2)

There was a window between this commit:

http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/old-2.6-bkcvs.git;a=3D=
commit;h=3Defa7fb249453d753985ac96297593e950f3621e0

and this one:

http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/old-2.6-bkcvs.git;a=3D=
commit;h=3Dca5453fe96bff15a1673900fdb5494b076aee22b

where EWOULDBLOCK was translated.

Not sure what kernel version(s) that corresponded to....

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
