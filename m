From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 12:07:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030114170755.GA18952@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YUXd-0007YB-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 09:07:57 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id A932CAB64F
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 12:07:55 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com>
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

Lever, Charles on Tue 14/01 07:56 -0800:
> however, if there are no outstanding RPCs on the client, but
> the server is not available, umount -f works as advertised.

I think his point was that Solaris will allow root to umount -f in any
case.

Right now I have to reboot my Linux NFS clients remotely with a "sync;
reboot -f" if they are stuck on a stale mount.  `init 6' will time out
forever trying to unmount NFS filesystems (and yes, the init scripts use
`-f'), and by that time my sshd is killed so I have to drive out to the
colo site.


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
