From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits
	during chown
Date: Thu, 15 Dec 2005 13:51:36 -0500
Message-ID: <1134672696.7956.4.camel@lade.trondhjem.org>
References: <20051215130939.GA8111@hmsreliant.homelinux.net>
	 <1134656087.7954.7.camel@lade.trondhjem.org>
	 <20051215144945.GA8376@hmsreliant.homelinux.net>
	 <1134658644.7954.13.camel@lade.trondhjem.org>
	 <20051215163834.GB8376@hmsreliant.homelinux.net>
	 <43A19E51.1060901@redhat.com> <1134667920.7944.14.camel@lade.trondhjem.org>
	 <20051215181746.GC8376@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmyD9-0005UH-4k
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 10:52:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmyD6-00020W-TR
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 10:52:15 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20051215181746.GC8376@hmsreliant.homelinux.net>
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

On Thu, 2005-12-15 at 13:17 -0500, Neil Horman wrote:

> >  2) Rely on the server clearing the suid/sgid mode bit.
> > 
> But you just Nacked my version of the patch which does exactly that, on the
> basis that were trying to second guess the intent of the VFS, so it seems like
> your trying to have it both ways here.  I suppose we could not mask off the
> KILL_SUID flag in ia_valud up in notify_change, and supress the mode
> modification in nfs_setattr based on that KILL_SUID flag (trusting that the
> server will do it for us).  That way we could be clear on the intent of the VFS.
> How does that sound?

No. This needs to be fixed in the VFS.

A correct patch would move the gunk in notify_change() that "interprets"
KILL_SUID/KILL_SGID and sets ATTR_MODE into inode_setattr(), then fix up
the users that don't call inode_setattr() to do the right thing.

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
