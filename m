From: Sampo Nurmentaus <audiopoppi-13@audioriders.fi>
Subject: Re: Weird error with nfs server and an embedded linux system.
Date: Mon, 29 Jul 2002 17:11:24 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0207291705350.12454-100000@localhost>
References: <shs65yy4qwx.fsf@charged.uio.no>
Reply-To: <sampo.nurmentaus@audioriders.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs150121.pp.htv.fi ([213.243.150.121])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZBFP-00069W-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 07:11:43 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs65yy4qwx.fsf@charged.uio.no>
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


Thanks for the tip Trond,

It really seems that there is something wierd going on.

Portmapping seems to work fine and mount
appears in rmtab but then ethereal reports
something it calls: "Unknown WCCP package"

I first thought that this is related to some other traffic
between these machines but this wierd packet is sent
from my laptop to the server every time the error occurs!

For some reason ethereal was not able to parse all
rpc calls only those made by portmap.

Have anyone seens this kind of behaviour before?


Sampo

> >>>>> " " == Sampo Nurmentaus <audiopoppi-13@audioriders.fi> writes:
>
>      > Hello folks,
>
>      > I ported all the nfs stuff to our embedded system running
>      > 2.4.14 on cris platform.  All the daemons start up nicely
>      > except the statd that prints to log that:
>
>      > Jul 29 12:58:06 noisy25 statd[124]: Version from Hell! Starting
>
>      > But it starts up anyway.
>
>      > When I try to mount a share it ses in syslog that mount request
>      > is authenticated and my laptops ip appears in xtab but still
>      > the mount fails with fallowing error message:
>
>      > [root@kombo root]# mount -t nfs -o nolock
>      > 120.100.100.25:/tmp/hd /mnt/keke/ mount: RPC: Remote system
>      > error
>
> If you are mounting using 'nolock', then you won't care if statd is
> running or not. rpc.statd is only required if you need file locking
> over NFS.
>
> Your mount error is therefore likely to be due to some other
> problem. I suggest you have a look at the RPC exchange between client
> and server using the 'ethereal' program. That should show you what is
> going wrong...
>
> Cheers,
>   Trond
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: Dice - The leading online job board
> for high-tech professionals. Search and apply for tech jobs today!
> http://seeker.dice.com/seeker.epl?rel_code=31
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
