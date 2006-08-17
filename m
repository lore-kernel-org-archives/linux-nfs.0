From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Thu, 17 Aug 2006 16:49:18 +1000
Message-ID: <17636.4462.975774.528003@cse.unsw.edu.au>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDbh5-0001JA-OB
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 23:49:33 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GDbh4-0006t0-JH
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 23:49:31 -0700
To: "Jesper Juhl" <jesper.juhl@gmail.com>
In-Reply-To: message from Jesper Juhl on Tuesday August 8
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

On Tuesday August 8, jesper.juhl@gmail.com wrote:
> I have some webservers that have recently started reporting the
> following message in their logs :
> 
>   do_vfs_lock: VFS is out of sync with lock manager!


I can imagine that happening if you mount with '-o nolocks'.
Then a non-blocking lock could cause that message (I think).
Can you conform that you aren't using 'nolocks'.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
