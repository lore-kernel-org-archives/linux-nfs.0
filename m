From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: RPC request reserved 240 but used 244
Date: Tue, 24 Sep 2002 14:34:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15759.60220.487804.644136@notabene.cse.unsw.edu.au>
References: <3D8F1615.5000606@chrysalisdev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17thOo-0001Au-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Sep 2002 21:34:14 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <jsantiago@chrysalisdev.com>) (for <nfs@lists.sourceforge.net>)
	By tone With Smtp ; Tue, 24 Sep 2002 14:34:03 +1000
To: Jose Santiago <jsantiago@chrysalisdev.com>
In-Reply-To: message from Jose Santiago on Monday September 23
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Monday September 23, jsantiago@chrysalisdev.com wrote:
> I am seeing messages similar to the following in my kernel log since I 
> upgraded to 2.4.19. I have installed Trond's NFS_ALL patches and the 
> linux-2.4.19-30-neilb.dif patch from Trond's NFS patches site. Is this 
> something I need to worry about?

I cannot seem to find Trond's site just at the moment to check, but I
suspect that it is an oldish patch with some arithmetic errors in it.
The correct (I hope:-) version of this patch is in 2.4.20-pre so maybe
you could try that, or compare fs/nfsd/nfsproc.c and
fs/nfsd/nfs3proc.c

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
