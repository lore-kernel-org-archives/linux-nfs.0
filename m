From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 10:09:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803080913.GC21365@suse.de>
References: <20040802162448.GB21365@suse.de> <20040803021018.GG5581@sgi.com> <20040803060213.GA21134@suse.de> <20040803075506.GL5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BruMI-0000Yv-VR
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 01:09:18 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BruMI-0002aE-DR
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 01:09:18 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040803075506.GL5581@sgi.com>
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

On Tue, Aug 03, 2004 at 05:55:06PM +1000, Greg Banks wrote:
> I think another useful approach would be to writeback pages which
> have been written by NFS unstable writes at a faster rate than pages
> written by local applications, i.e. add a new /proc/vm/ sysctl like
> nfs_dirty_writeback_centisecs and a per-page flag.

The problem with this approach is that we have no access to the
pages. nfsd_write goes through writev.

> > That may be a useful solution, too. My patch basically does what
> > fadvise(WONTNEED) does.
> 
> Sure, the key question is when and for how many pages.  You don't
> really have enough information in nfsd_write() to tell that safely.

Well, for streaming writes "everything we've written so far" is a
reasonable approximation. Random writes may receive a penalty, I
admit.

> It writes every time `offset' is a multiple of 64 times `cnt' and
> `cnt' is a multiple of 1024.  At this point `cnt' is the length
> of the data received in the WRITE call, which has only a vague
> relationship to the client page size.

Okay, I should have been more precise: the test tries to make
sure we're seeing a full wsize worth of data, which is usually a
good indication of writes being streamed, and tries to lump
enough of them together to allow the file system to make an
intelligent decision.

I'm not claiming this is god's wisdom - I'm trying out ideas :)

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
