From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 14:45:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405271445.37049.vincent.roqueta@ext.bull.net>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi> <200405271251.22746.vincent.roqueta@ext.bull.net> <Pine.LNX.4.58.0405271515570.11088@penti.sit.fi>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTKCz-0004au-20
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:42:05 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTKCx-0005kk-HD
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:42:03 -0700
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id OAA12988
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 14:43:31 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.58.0405271515570.11088@penti.sit.fi>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Le Jeudi 27 Mai 2004 14:17, Harald Hannelius a =E9crit :
> On Thu, 27 May 2004, Vincent ROQUETA wrote:
> > Le Jeudi 27 Mai 2004 12:31, Harald Hannelius a =E9crit :
> > > Is there some way I can look at the nfs-server what it's doing? Any
> > > suggestions on solutions for this?
> > >
> > > And what datarates over NFS could I expect on a setup like this?
> > > Half-wirespeed maybe?
> >
> > on NFSv3, 1 ethernet 1GB I reached  89% of the avalaible brandwith for
> > NFSv3, kernel 2.6.3, for file less than the total amount of ram (4Go),
> > and 22% of the brandwith for file over 6Go, because of the use of
> > harddisk use in the copy process (swap).
> >
> > What is  your memory configuration?
>
> I took a look at "top" while reading the file on the client;
>
> It looks like it's sitting there waiting for io. Something for the
> kernel-people maybe?
>
>  15:15:10  up 1 day, 19:31,  4 users,  load average: 7.55, 4.31, 3.54
> 93 processes: 92 sleeping, 1 running, 0 zombie, 0 stopped
> CPU0 states:   0.0% user   1.2% system    0.0% nice  95.1% iowait   3.0%
> idle
> CPU1 states:   0.0% user   1.2% system    0.0% nice  90.1% iowait   8.1%
> idle
> Mem:  1035184k av, 1029660k used,    5524k free,       0k shrd,   18216k
> buff
>         52712k active,             929460k inactive
> Swap:  987956k av,       0k used,  987956k free                  957788k
> cached
>
>   PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND
>  4473 root      16   0  4008 1084  3832 R     0.3  0.1   0:00   1 top
>     8 root       5 -10     0    0     0 SW<   0.1  0.0   0:15   0
> kblockd/0
>     9 root       5 -10     0    0     0 SW<   0.1  0.0   0:14   1
> kblockd/1
>  4382 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
>  4384 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
>  4386 root      15   0     0    0     0 DW    0.1  0.0   0:01   1 nfsd
>  4387 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
>  4392 root      15   0     0    0     0 DW    0.1  0.0   0:01   0 nfsd
>  4394 root      15   0     0    0     0 DW    0.1  0.0   0:00   1 nfsd
>  4395 root      15   0     0    0     0 SW    0.1  0.0   0:00   1 nfsd
>  4396 root      15   0     0    0     0 DW    0.1  0.0   0:01   0 nfsd
>     1 root      16   0   488  240   464 S     0.0  0.0   0:05   1 init

That's normal : waiting for IO -> probably waiting for reading something fr=
om=20
the network. I am trying to do the same experience.




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
