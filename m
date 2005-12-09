From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: mtime not updated in client cache?
Date: Fri, 9 Dec 2005 07:56:37 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E201332862@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "Vince Busam" <vbusam@google.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekkc5-00086k-5s
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 07:56:49 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ekkc4-0006bi-2l
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 07:56:49 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Peter Staubach" <staubach@redhat.com>
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

> On Fri, 2005-12-09 at 09:24 -0500, Peter Staubach wrote:
>=20
> > >One alternative would be to flush dirty data to the server=20
> on every call
> > >to stat(), but that would slow it down considerably.

only in certain cases.  i can think of one:  'ls -l' in a directory full
of data files for an active Oracle instance.

> > Yes, to this last, but this is how most NFS implementations=20
> that I have seen
> > conform to the requirment that write(2) cause the mtime to=20
> be updated.  The
> > use of UNSTABLE NFSv3/NFSv4 writes can help as well as=20
> limiting the amount
> > of dirty data that the client allows to be cached.
>=20
> My main concern is that it will hit commands like 'ls -l' _hard_. The
> latter will, for instance, be forced to wait until all=20
> pending writes on
> all files in the directory have been flushed out. I'm not sure that
> strict POSIX compatibility is worth that kind of hit.
>=20
> Anyhow, the attached patch implements it. Lets try it out, and see how
> it does. Definitely _not_ a 2.6.15 candidate, though.

i like the idea.

do you need to prevent writes *during* the stat() call?  or do you just
want to make sure that any writes that happened *before* the stat() call
have the intended side-effects on the file size and mtime?  that might
be worth a comment or two.

are you flushing dirty mmap'd data too?  or can this be skipped until
msync() time?

and now that you have added a "flush but don't commit" flag to
nfs_sync_file, maybe we might consider using that (optionally) at file
close() time, like some other NFS client implementations do.  :^)


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
