From: "Cole, Timothy D." <tdcole@northropgrumman.com>
Subject: RE: Re: broken umount -f
Date: Wed, 15 Jan 2003 10:46:42 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7F21D7A9E7D9D51192CB0002A53F93C73C28E8@xcgmd024.md.essd.northgrum.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from xcgmd811.northgrum.com ([155.104.240.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Yt1a-00057q-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 11:16:30 -0800
To: 'Scott Mcdermott' <smcdermott@questra.com>, nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> -----Original Message-----
> From: Scott Mcdermott [mailto:smcdermott@questra.com]
> Sent: Wednesday, January 15, 2003 12:24
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Re: broken umount -f
> 
> User saving his mail spool, sees "nfs server not responding, still
> trying" and decides to try killing his MUA.  Too bad it works and now
> his spool is a steaming pile of ASCII.

That's possible with non-NFS filesystems too -- just normally a smaller
window of opportunity.  It doesn't require a filesystem hang in any case --
most mailbox operations are not a single atomic write().  Imagine someone
killing the MUA in the middle of deleting a large mail from a ~40MB mail
spool on any filesystem, local or remote.

Also consider the nointr case -- process hangs, user can't kill it, user
naively closes the terminal window.  Server comes back up.  SIGHUP is
finally handled when the write() returns.  Process dies.  ASCII soup again.

This is of course assuming that the NFS server _can_ come back up.  If not,
totally unkillable processes are a pain-in-the-ssh.

> `soft' and `intr' are evil and should be banned.

Agreed WRT soft's evil-ness, anyway.  But hard,intr seems to be a pretty
good combination, as far as safety from data corruption, and from a
standpoint of not having to reboot-and-kill-week-long-simulations just
because a few unrelated (but important) processes got wedged by a
recalcitrant NFS server.


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
