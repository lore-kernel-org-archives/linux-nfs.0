From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 19:20:53 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203210020.g2L0KrB13635@moisil.badula.org>
References: <3C98D3AF.8091F420@amis.com>
Cc: nfs@lists.sourceforge.net
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=moisil.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nqKC-0004ta-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 16:21:00 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3C98D3AF.8091F420@amis.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, 20 Mar 2002 11:23:43 -0700, Eric Whiting <ewhiting@amis.com> wrote:

> ==THIRD TEST
> Same setup as second test, but using dd instead of bonnie
> 
> mohawk/test> time dd if=/dev/zero of=file bs=1024k count=1
> 1+0 records in
> 1+0 records out
> 0.000u 0.030s 0:05.06 0.5%      0+0k 0+0io 136pf+0w
> 
> About 200k/s on a 100Mbit network -- not very good.

Umm... no. I don't recall your setup (and you didn't specify it
in your email), but if this is the same setup as Lee's (GigE 
bridged into 100Mbit), then you don't really have a 100Mbit network.
What you have is a GigE network with 90% packet loss. 200k/s is
actually pretty good in that case.

This is what Trond has been trying to say all along: UDP is a losing
proposition for this kind of setup. The only way you can make it work
sort of ok is by slowing it down and thus penalizing the rest of us
with sane setups.

Just use TCP and be happy.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
