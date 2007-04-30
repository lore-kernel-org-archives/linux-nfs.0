From: Neil Brown <neilb@suse.de>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Tue, 1 May 2007 07:24:07 +1000
Message-ID: <17974.24183.309814.609652@notabene.brown>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
	<46362BC8.9040305@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Kottaridis,  Chris" <chris.kottaridis@windriver.com>
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HidMO-0004BF-Sb
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 14:24:40 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HidMQ-000581-39
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 14:24:43 -0700
In-Reply-To: message from Gabriel Barazer on Monday April 30
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday April 30, gabriel@oxeva.fr wrote:
> I have this problem too for a long time and already reported it, but 
> propably forgotten. My rpc.mountd is actually 350MB and continue 
> growing, with nfs-utils 1.1.0-rc2:
> 
> # rpc.mountd --version
> kmountd 1.1.0-rc2

Is this compiled with libblkid (the default)?
There is a memory leak in libblkid that was only fixed quite recently
so unless your libblkid is very new, you should use
    ./configure --without-uuid

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
