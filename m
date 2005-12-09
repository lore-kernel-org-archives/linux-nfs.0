From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: mtime not updated in client cache?
Date: Fri, 9 Dec 2005 11:07:03 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E201332866@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EknaJ-0007XO-R4
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:07:11 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EknaH-0004FG-Iq
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:07:11 -0800
To: "Peter Staubach" <staubach@redhat.com>
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

hi peter-

> >and now that you have added a "flush but don't commit" flag to
> >nfs_sync_file, maybe we might consider using that=20
> (optionally) at file
> >close() time, like some other NFS client implementations do.  :^)
>=20
> This seems like a pretty dangerous thing to do.  I've thought about it
> because it would seem to make close-to-open less expensive, but it=20
> introduces
> the possibility of data loss without the application being=20
> aware.  If the
> data is not committed at close(2), then if it can not be=20
> committed when it
> needs to be committed, then there is no way to return an error to the
> application.  A somewat contrived but still possible scenario=20
> is that the
> server crashes, comes back up, and the file system fills up=20
> before the client
> can retransmit all of the data.  In this case, the data will=20
> be lost, but
> the application thought that it was all stored because no system calls
> returned any errors.

risks understood.

however, how is this different from ext3?  a close() on an ext3 file
doesn't even attempt to schedule a flush of the data to disk.  if the
system crashes or the disk dies or the file system fills up, the data is
lost, just like in the NFS case.

in addition, mapped dirty data is never flushed on close() on NFS.  what
happens if a server failure pins dirty mapped pages in the client's
memory?

if an application really wants the guarantee that the data is
permanently stored or have the opportunity to recover if an error
occurs, it will use O_SYNC or msync() or fflush() before closing the
file.

to make a more philosophical argument, UNIX has always compromised data
integrity for performance in the common case.  for example, why aren't
there more file systems around that provide ACID semantics?  because in
99.9% of cases, ACID semantics are simply not required, and just slow
everything else down.

i think this is reasonable behavior to enable with either a mount option
or a sysctl.  we have "nocto," after all.

i'm not trying to start an argument.  just wondering aloud.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
