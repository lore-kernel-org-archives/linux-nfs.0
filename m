From: Neil Brown <neilb@suse.de>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Wed, 2 May 2007 21:30:59 +1000
Message-ID: <17976.30323.561073.317868@notabene.brown>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
	<46362BC8.9040305@oxeva.fr>
	<17974.24183.309814.609652@notabene.brown> <46366B82.105@oxeva.fr>
	<17974.47175.736725.527504@notabene.brown>
	<463857E5.9030901@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Kottaridis,  Chris" <chris.kottaridis@windriver.com>
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjD3P-0000PV-CA
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:31:27 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjD3Q-0001m1-Co
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:31:30 -0700
In-Reply-To: message from Gabriel Barazer on Wednesday May 2
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

On Wednesday May 2, gabriel@oxeva.fr wrote:
> On 05/01/2007 5:47:19 +0200, Neil Brown <neilb@suse.de> wrote:
> 
> > On Tuesday May 1, gabriel@oxeva.fr wrote:
> >> I will try with mountd compiled without libblkid, although my version is 
> >> the most up to date release : 1.39 from e2fsprogs.
> > 
> > Bug is in 1.39, will be fix in 1.40.  More info at
> >    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=413661
> > 
> 
> I think the bug was indeed related to the libblkid memleak : 100's of 
> mounts later, mountd size is kept low ~ 1MB.
> 
> Is this dependency to libblkid really needed in the nfs-utils ? 
> According to the mountd sources (the only place where there is BLKID 
> related code), the get_uuid function in onyl used in the nfsd_fh 
> function, used to find a mount point from a fsid export entry.
> 
> Since the current version of e2fsprogs is still 1.39, this bug is likely 
> to happen to much people, hence the best thing to do would be disabling 
> the uuid support by default, wouldn't be ?

Yes... I guess it should default to not providing uuid support unless
e2fsprogs 1.40 or later is installed.  People with a prepatch should
still be able to do that.
I'll see if I can work out the auto-conf magic to make that happen
(though as I cannot install 1.40 or later, it might be hard to
test completely....)

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
