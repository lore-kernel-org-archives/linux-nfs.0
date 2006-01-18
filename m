From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Another hang problem - Jukebox error (was: NFS hangs for
	15 seconds after exportfs -r)
Date: Wed, 18 Jan 2006 16:14:04 -0500
Message-ID: <1137618844.8706.35.camel@lade.trondhjem.org>
References: <C664ABFF405D6A458806C03AA2E0FF6B06CBC744@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzKdS-0006LN-9b
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:14:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzKdQ-0004DU-RG
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:14:30 -0800
To: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
In-Reply-To: <C664ABFF405D6A458806C03AA2E0FF6B06CBC744@MKEMLVEM01.e2k.ad.ge.com>
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

On Wed, 2006-01-18 at 11:35 -0600, Edwards, Scott (GE Healthcare) wrote:

> I compared the nfs code from kernel 2.6.6 (our old kernel that
> worked) and 2.6.9 (that causes the error) and discovered that there
> was an addition of a JUKEBOX error from an EWOULDBLOCK in nfsproc.c.
> I couldn't find a difference that would explain why we would be 
> getting an error when we didn't before (mostly because there were 
> so many changes I couldn't figure out which one could cause an 
> error).

AFAICS knfsd will translate ETIMEDOUT into NFS3ERR_JUKEBOX, not
EWOULDBLOCK.

There are two operations in vfs.c that can directly cause this error to
appear:

  setattr if someone else is holding a lease on the file.
  open if someone else is holding a lease on the file.

The only programs I know of that use leases are: knfsd itself (if you
have NFSv4 clients that support delegations) and Samba (in order to
support CIFS oplocks).

Any NFSv4 or Samba activity on this machine?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
