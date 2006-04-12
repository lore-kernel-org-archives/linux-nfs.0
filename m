From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fileid changed messages appearing after upgrade to
	2.6.16.1
Date: Tue, 11 Apr 2006 23:10:31 -0400
Message-ID: <1144811431.8069.6.camel@lade.trondhjem.org>
References: <443C69CB.4060503@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTVkp-0000aW-70
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 20:10:51 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTVkn-0008D8-Lz
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 20:10:51 -0700
To: Vince Busam <vbusam@google.com>
In-Reply-To: <443C69CB.4060503@google.com>
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

On Tue, 2006-04-11 at 19:45 -0700, Vince Busam wrote:
> After upgrading from 2.6.13.4 + CITI NFS patch to 2.6.16.1 (with no
> patches), I've started seeing error messages like the following:
> 
> NFS: server build.nfs error: fileid changed
> fsid 0:17: expected fileid 0x5d3644, got 0x5d363c
> nfs_update_inode: inode 6108740 mode changed, 0040755 to 0000000
> 
> The equivalent errors (the printk output was moved and changed) did not
> show up with 2.6.13.4.  Is this a known issue, or is there anything I
> can do to help pinpoint the problem?

What did you upgrade? The client or the server? What mount options etc,
etc....

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
