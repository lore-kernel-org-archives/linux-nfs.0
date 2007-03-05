From: Neil Brown <neilb@suse.de>
Subject: Re: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Mon, 5 Mar 2007 13:05:21 +1100
Message-ID: <17899.31457.535979.478100@notabene.brown>
References: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Matt Proud" <matt.proud.list@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO2b3-00028c-BA
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 18:06:41 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HO2b5-0006oU-3n
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 18:06:43 -0800
In-Reply-To: message from Matt Proud on Sunday March 4
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

On Sunday March 4, matt.proud.list@gmail.com wrote:
> 
> When rpc.mountd acts funny, an attached strace reveals the a select
> function call occurring very rapidly:
> 
> select(1024, [3 4 5 6 7 32 33 34 35 36 37 38 39 40], NULL, NULL, NULL)
> = 9 (in [32 33 34 35 36 37 38 39 40])

It would help if we could see matching "lsof -p xxx" output to see
exactly what those 9 fds are, but they are presumably tcp connections.

I cannot imagine why mountd would spin on something like that - if
select says that it can read from those fds, it should try to read...

It might be worth trying a newer nfs-utils.  Just grab
1.0.12 from
   http://www.kernel.org/pub/linux/utils/nfs/

./configure --without-nfsv4 --without-gss
make

then kill mountd and run ./utils/mountd/mountd

See if that makes a difference.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
