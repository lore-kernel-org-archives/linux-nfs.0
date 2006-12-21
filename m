From: Neil Brown <neilb@suse.de>
Subject: Re: fsid and stale-filehandle
Date: Fri, 22 Dec 2006 10:11:52 +1100
Message-ID: <17803.5304.326896.669709@cse.unsw.edu.au>
References: <E1GxLvL-0014jr-6F@alf1.lmb.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GxX4U-0003wQ-Fs
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 15:11:30 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GxX4U-0007iN-EL
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 15:11:32 -0800
To: "T. Horsnell" <tsh@mrc-lmb.cam.ac.uk>
In-Reply-To: message from T. Horsnell on Thursday December 21
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

On Thursday December 21, tsh@mrc-lmb.cam.ac.uk wrote:
> I want to use the exports fsid= option to avoid 
> 'NFS stale-filehandle' errors, but have some questions.

Are you getting these errors because the major/minor numbers of your
devices keep changing?  That is the only reason I can think of there
fsid= would make a difference.

> 
> 1. If I use the fsid= option for any filesystem in
>    my exportfs file, do I have to use it for *all*
>    entries? If not, how do I avoid choosing an fsid
>    which may be the same as one calculated by the system
>    for those entries where I havent specified it?

No, you don't have to use it for all entries.
You cannot choose an fsid which is the same as one calculated by the
system.  system-chosen number and user-chosen number are in separate
number-spaces. 

> 
> 2. Someone on the fedora list said that export options
>    chosen for a filesystem with a particular fsid will
>    apply to *all* clients using that fsid. So that if
>    I have exports entries like:
> 
>    /filesystem client1(ro,fsid=10) client2(rw,fsid=10)
> 
>    either the filesystem will be exported ro to both
>    clients, or it will be exported rw to both, (he
>    couldnt say which would take precedence).
>    Is this correct? Do I have to use a different fsid
>    for each filesystem/client pair if I want different
>    export options for them?

No, this isn't correct.  The different clients will get different
export options.  They can have different fsids, but there is no need
(and it would probably just be confusing).

> 
> 3. According to 'man stat', 'stat -f /filesystem' should show me
>    the filesystem ID in hex of /filesystem, but all I get is
>    zero for my exported fs's:
> 
> [root@dev1 ~]# stat -f /test10
>   File: "/test10"
>     ID: 0        Namelen: 255     Type: ext2/ext3
> Block size: 4096       Fundamental block size: 4096
> Blocks: Total: 8750377    Free: 8705316    Available: 8260818
> Inodes: Total: 4447744    Free: 4447732
> [root@dev1 ~]# stat -f /test11
>   File: "/test11"
>     ID: 0        Namelen: 255     Type: ext2/ext3
> Block size: 4096       Fundamental block size: 4096
> Blocks: Total: 2520130    Free: 1393714    Available: 1265697
> Inodes: Total: 1281696    Free: 1106401
> [root@dev1 ~]# 

ext3 only got support the fsid (ID: in stat -f) very recently.  It
isn't in 2.6.18 and early.
But this fsid is completely unrelated to the nfsd fsid.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
