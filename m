From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 18:47:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097858875.5558.98.camel@lade.trondhjem.org>
References: <20041015095840.GA22992@suse.de>
	 <1097851471.5558.12.camel@lade.trondhjem.org>
	 <20041015151257.GF27307@suse.de>  <20041015152156.GH27307@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIVGS-0003Od-AB
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 09:49:12 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CIVFU-0000S6-T7
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 09:49:12 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041015152156.GH27307@suse.de>
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

P=E5 fr , 15/10/2004 klokka 17:21, skreiv Olaf Kirch:
> > Urrrgh.. this looks complicated and duplicates code. Then I'd rather
> > have two struct file_operations, one for normal operations with a .lock
> > function, and a second one for nolock without.

Huh? Those 3 tests are exactly what we had prior to 2.6.9-rc2. I've just
moved the LOCK_USE_CLNT option into the filesystem. In fact it does the
same thing with LESS code than what used to be the case (the 2 combined
patches remove 31 lines, and insert 20).

> Please find attached proposed fix3 that does just this.

Hmm... I agree that is slightly more efficient. The worry I have is that
the "nolock" option is a mountpoint option; it's not really a file
property.
If we ever want to be able to move options like "-onolock" to the
vfsmount, so that people can have the same underlying filesystem mounted
in different places with several different sets of mount options, then
we should not mix mount options and file properties.

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
