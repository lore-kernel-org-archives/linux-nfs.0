From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 11:10:36 -0500
Message-ID: <1134144637.8007.56.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E201332862@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>,
	Vince Busam <vbusam@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekkq3-0000is-HG
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 08:11:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ekkpx-00055A-Rm
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 08:11:15 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E201332862@exsvl02.hq.netapp.com>
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

On Fri, 2005-12-09 at 07:56 -0800, Lever, Charles wrote:
> do you need to prevent writes *during* the stat() call?  or do you just
> want to make sure that any writes that happened *before* the stat() call
> have the intended side-effects on the file size and mtime?  that might
> be worth a comment or two.

I cannot see that we would want strict serialisation of stat() and
write(). That would give rise to an even worse performance hit.
If someone calls write() while we're in stat() then the outcome should
be indeterminate, just as it is for local filesystems.

> are you flushing dirty mmap'd data too?  or can this be skipped until
> msync() time?

There appears to be no SuS requirement to do so: the description of
msync() says that you are only required to update m/ctime if writes are
actually initiated.

  http://www.opengroup.org/onlinepubs/009695399/toc.htm

> and now that you have added a "flush but don't commit" flag to
> nfs_sync_file, maybe we might consider using that (optionally) at file
> close() time, like some other NFS client implementations do.  :^)

Nope.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
