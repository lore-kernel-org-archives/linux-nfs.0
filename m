From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 16:44:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097851471.5558.12.camel@lade.trondhjem.org>
References: <20041015095840.GA22992@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CITK6-0003Cs-N0
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 07:44:50 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CITK5-0000iQ-FP
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 07:44:50 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041015095840.GA22992@suse.de>
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

P=E5 fr , 15/10/2004 klokka 11:58, skreiv Olaf Kirch:

> I don't know why this change was made. The patch below simply reverts
> these two hunks; maybe there's a better solution involving LOCK_USE_CLNT
> the way it's used for F_GETLK at the moment.

NO! The correct way to do this is to handle it with a call to
posix_lock_file() in the NFS code for the particular case of "nolock".

See

http://linux.bkbits.net:8080/linux-2.6/cset@412a5e26rbgf-d7ofSTJKn9DIGumag

for details on why the changes were made (and that should make it
obvious why your patch is wrong). The VFS must NOT be allowed to
interfere if a filesystem has its own ->lock() method: that will violate
the ability of filesystems to impose rigid locking rules.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
