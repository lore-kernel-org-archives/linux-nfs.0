From: Harald Hannelius <harald+nfs@arcada.fi>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 15:17:43 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405271515570.11088@penti.sit.fi>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
 <200405271251.22746.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJpR-0000dI-BU
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:17:45 -0700
Received: from penti.sit.fi ([193.167.33.237])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJpQ-0008VX-Ih
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:17:44 -0700
Received: from penti.sit.fi (harald@localhost [127.0.0.1])
	by penti.sit.fi (8.12.10/8.12.10) with ESMTP id i4RCHhgT011157
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 15:17:43 +0300
Received: from localhost (harald@localhost)
	by penti.sit.fi (8.12.10/8.12.9/Submit) with ESMTP id i4RCHhYr011154
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 15:17:43 +0300
To: nfs@lists.sourceforge.net
In-Reply-To: <200405271251.22746.vincent.roqueta@ext.bull.net>
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


On Thu, 27 May 2004, Vincent ROQUETA wrote:

> Le Jeudi 27 Mai 2004 12:31, Harald Hannelius a =E9crit :

> > Is there some way I can look at the nfs-server what it's doing? Any
> > suggestions on solutions for this?
> >
> > And what datarates over NFS could I expect on a setup like this?
> > Half-wirespeed maybe?

> on NFSv3, 1 ethernet 1GB I reached  89% of the avalaible brandwith for NF=
Sv3,
> kernel 2.6.3, for file less than the total amount of ram (4Go), and 22% o=
f
> the brandwith for file over 6Go, because of the use of harddisk use in th=
e
> copy process (swap).
>
> What is  your memory configuration?

I took a look at "top" while reading the file on the client;

It looks like it's sitting there waiting for io. Something for the
kernel-people maybe?

 15:15:10  up 1 day, 19:31,  4 users,  load average: 7.55, 4.31, 3.54
93 processes: 92 sleeping, 1 running, 0 zombie, 0 stopped
CPU0 states:   0.0% user   1.2% system    0.0% nice  95.1% iowait   3.0%
idle
CPU1 states:   0.0% user   1.2% system    0.0% nice  90.1% iowait   8.1%
idle
Mem:  1035184k av, 1029660k used,    5524k free,       0k shrd,   18216k
buff
        52712k active,             929460k inactive
Swap:  987956k av,       0k used,  987956k free                  957788k
cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND
 4473 root      16   0  4008 1084  3832 R     0.3  0.1   0:00   1 top
    8 root       5 -10     0    0     0 SW<   0.1  0.0   0:15   0
kblockd/0
    9 root       5 -10     0    0     0 SW<   0.1  0.0   0:14   1
kblockd/1
 4382 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
 4384 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
 4386 root      15   0     0    0     0 DW    0.1  0.0   0:01   1 nfsd
 4387 root      15   0     0    0     0 SW    0.1  0.0   0:01   0 nfsd
 4392 root      15   0     0    0     0 DW    0.1  0.0   0:01   0 nfsd
 4394 root      15   0     0    0     0 DW    0.1  0.0   0:00   1 nfsd
 4395 root      15   0     0    0     0 SW    0.1  0.0   0:00   1 nfsd
 4396 root      15   0     0    0     0 DW    0.1  0.0   0:01   0 nfsd
    1 root      16   0   488  240   464 S     0.0  0.0   0:05   1 init


--=20
A: Top Posters
Q: What is the most annoying thing on mailing lists?

Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
