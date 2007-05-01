From: Neil Brown <neilb@suse.de>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Tue, 1 May 2007 13:47:19 +1000
Message-ID: <17974.47175.736725.527504@notabene.brown>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
	<46362BC8.9040305@oxeva.fr>
	<17974.24183.309814.609652@notabene.brown> <46366B82.105@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Kottaridis,  Chris" <chris.kottaridis@windriver.com>
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HijL7-0006Ri-QW
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 20:47:46 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HijL9-0000Kf-9S
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 20:47:48 -0700
In-Reply-To: message from Gabriel Barazer on Tuesday May 1
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

On Tuesday May 1, gabriel@oxeva.fr wrote:
> I will try with mountd compiled without libblkid, although my version is 
> the most up to date release : 1.39 from e2fsprogs.

Bug is in 1.39, will be fix in 1.40.  More info at
   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=413661

> 
> Do I have to apply the previously posted patch as well ?
> 

No, that fix in already in 1.1.0-rc2

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
