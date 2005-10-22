From: Ian Kent <raven@themaw.net>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sat, 22 Oct 2005 12:19:39 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0510221218370.2552@donald.themaw.net>
References: <20051021220205.410.qmail@web52402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETAro-00058F-94
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 21:20:24 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ETArm-0000A3-KV
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 21:20:24 -0700
To: Jun Zhang <nugulus@yahoo.com>
In-Reply-To: <20051021220205.410.qmail@web52402.mail.yahoo.com>
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

On Fri, 21 Oct 2005, Jun Zhang wrote:

>  
> Many a time when I type df -k, the prompt will not come back. Went to another session, I found the df process is not killable. I then checked each piece in /etc/fstab, each piece is fine (mounted and accessible).
> Can somebosy give a clue?

Not fstab.

Try working out what is blocked by looking at /etc/mtab or /proc/mounts.

Ian



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
