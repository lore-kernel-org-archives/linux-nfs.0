From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 00:21:38 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115052138.GC30478@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551EB@black.eng.netapp.com> <20030115051928.GB30478@questra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Yfzg-000422-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 21:21:40 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 7DC88AB7DA
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 00:21:38 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20030115051928.GB30478@questra.com>
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

To nfs@lists.sourceforge.net on Wed 15/01 00:19 -0500:
> Lever, Charles on Tue 14/01 11:36 -0800:
> <on client>

forgot to include

# grep nfsserver /proc/mounts
nfsserver:/tmp /mnt/tmp nfs rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=nfsserver 0 0


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
