From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Wed, 02 May 2007 11:20:37 +0200
Message-ID: <463857E5.9030901@oxeva.fr>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>	<46362BC8.9040305@oxeva.fr>	<17974.24183.309814.609652@notabene.brown>	<46366B82.105@oxeva.fr>
	<17974.47175.736725.527504@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Kottaridis,  Chris" <chris.kottaridis@windriver.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjB1J-00084y-NM
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 02:21:09 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjB1L-00034a-TT
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 02:21:12 -0700
In-Reply-To: <17974.47175.736725.527504@notabene.brown>
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

On 05/01/2007 5:47:19 +0200, Neil Brown <neilb@suse.de> wrote:

> On Tuesday May 1, gabriel@oxeva.fr wrote:
>> I will try with mountd compiled without libblkid, although my version is 
>> the most up to date release : 1.39 from e2fsprogs.
> 
> Bug is in 1.39, will be fix in 1.40.  More info at
>    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=413661
> 

I think the bug was indeed related to the libblkid memleak : 100's of 
mounts later, mountd size is kept low ~ 1MB.

Is this dependency to libblkid really needed in the nfs-utils ? 
According to the mountd sources (the only place where there is BLKID 
related code), the get_uuid function in onyl used in the nfsd_fh 
function, used to find a mount point from a fsid export entry.

Since the current version of e2fsprogs is still 1.39, this bug is likely 
to happen to much people, hence the best thing to do would be disabling 
the uuid support by default, wouldn't be ?

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
