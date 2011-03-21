Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:48570 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab1CUOA2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 10:00:28 -0400
Subject: Re: rpc.statd hanging
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110321062915.GA5580@hostway.ca>
Date: Mon, 21 Mar 2011 10:00:21 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <C66ED0D2-9D52-41C1-9006-E152ED11C54F@oracle.com>
References: <20110321062915.GA5580@hostway.ca>
To: Simon Kirby <sim@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 21, 2011, at 2:29 AM, Simon Kirby wrote:

> Hello!
> 
> Something has been causing rpc.statd to start hanging, which causes
> "lockd" to stay in D state on the server, and "lockd: server x not
> responding, still trying" on the clients trying to make use of NLM
> locking (NFSv3) from this server.
> 
> This has happened now with old nfs-utils 1.1.2 and with 1.2.2 (upgraded
> after the first time it happened) on the server. It seems to be looping
> doing DNS lookups, and never seems to finish. The kernel's lockd keeps
> retransmitting requests, but rpc.statd doesn't seem to be finishing
> sm_notify_1_svc(), so everything stops.

At first blush, this looks like there are a bunch of monitor records for the same host, which isn't supposed to happen.  Statd is not supposed to have more than one monitor record for the same remote peer.  Or, some remote is pelting your statd with SM_NOTIFY requests...  Perhaps some network snooping of incoming traffic is in order.

What does "sudo ls /var/lib/nfs/statd/sm" say (assuming this is a RH-based distro)?  It could be a simple corruption of the on-disk monitor records.  You can clear these out by simply erasing the files in that directory before starting statd, lockd, and nfsd.  Or if they look vaguely abnormal, you could tar them up and send the tarball to me.

You can watch statd's operation by starting it on a terminal with the "-dF" option (see rpc.statd(8)).  You'll probably get more interesting output from statd from nfs-utils 1.2.2.  This would require restarting statd, however.  It should re-read active monitor records from disk on start-up, so I don't think you'd lose state by doing this.

More below.

> (gdb) bt
> #0  sm_notify_1_svc (argp=0x7fff46ef5430, rqstp=<value optimized out>) at callback.c:107
> #1  0x0000000000405a21 in sm_prog_1 (rqstp=0x7fff46ef59b0, transp=0x1b070e0) at sm_inter_svc.c:84
> #2  0x00007f674d5fafa1 in svc_getreq_common () from /lib/libc.so.6
> #3  0x00007f674d5fb034 in svc_getreqset () from /lib/libc.so.6
> #4  0x000000000040527a in my_svc_run () at svc_run.c:129
> #5  0x0000000000404cbd in main (argc=1, argv=<value optimized out>) at statd.c:472
> 
> sm_notify_1_svc():
>   |102             /* okir change: statd doesn't remove the remote host from its
>   |103              * internal monitor list when receiving an SM_NOTIFY call from
>   |104              * it. Lockd will want to continue monitoring the remote host
>   |105              * until it issues an SM_UNMON call.
>   |106              */
>> |107             for (lp = rtnl ; lp ; lp = lp->next)
>   |108                     if (NL_STATE(lp) != argp->state &&
>   |109                         (statd_matchhostname(argp->mon_name, lp->dns_name) ||
>   |110                          statd_matchhostname(ip_addr, lp->dns_name))) {
>   |111                             NL_STATE(lp) = argp->state;
>   |112                             call = nlist_clone(lp);
>   |113                             nlist_insert(&notify, call);
>   |114                     }
>   |115
>   |116
>   |117             return ((void *) &result);
>   |118     }
> 
> (gdb) print *rtnl
> $11 = {
>  mon = {
>    mon_id = {
>      mon_name = 0x1b07e80 "10.10.52.21",
>      my_id = {
>        my_name = 0x2a33b30 "nas08",
>        my_prog = 100021,
>        my_vers = 3,
>        my_proc = 16
>      }
>    }, 
>    priv = "\234\bq\000\000\233\001\210"
>  },
>  port = 0,
>  times = 5,
>  state = 0,
>  dns_name = 0x1e63140 "lsh1008.lsh",
>  next = 0x2961480,
>  prev = 0x0,
>  xid = 0,
>  when = 0
> }
> (gdb) print *lp                                                                      
> $12 = {
>  mon = {
>    mon_id = {
>      mon_name = 0x216b390 "10.10.52.28",
>      my_id = {
>        my_name = 0x216b370 "nas08",
>        my_prog = 100021,
>        my_vers = 3, 
>        my_proc = 16
>      }
>    }, 
>    priv = "005223\a\0338\000\000>\004\210"
>  }, 
>  port = 0,
>  times = 5,
>  state = 47, 
>  dns_name = 0x216b3b0 "lsh1015.lsh",
>  next = 0x216b220,
>  prev = 0x216b3e0,
>  xid = 0,   
>  when = 0
> }
> (gdb) set $x = rtnl
> (gdb) set $count = 0
> (gdb) while ($x->next)
>> set $count = $count + 1
>> set $x = $x->next
>> end
> (gdb) print $count
> $17 = 70916
> (gdb) print argp->state
> $18 = 89
> (gdb) print notify
> $19 = (notify_list *) 0x0
> (gdb) up
> #1  0x0000000000405a21 in sm_prog_1 (rqstp=0x7fff46ef59b0, transp=0x1b070e0) at sm_inter_svc.c:84
> (gdb) print rqstp
> $21 = (struct svc_req *) 0x7fff46ef59b0
> (gdb) print *rqstp
> $22 = {
>  rq_prog = 100024, 
>  rq_vers = 1, 
>  rq_proc = 6,    
>  rq_cred = {
>    oa_flavor = 0, 
>    oa_base = 0x7fff46ef54a0 "",
>    oa_length = 0
>  }, 
>  rq_clntcred = 0x7fff46ef57c0 "",
>  rq_xprt = 0x1b070e0
> }
> (gdb) print *transp  
> $23 = {
>  xp_sock = 7, 
>  xp_port = 33188,
>  xp_ops = 0x7f674d850840,
>  xp_addrlen = 16,
>  xp_raddr = {
>    sin_family = 2,
>    sin_port = 55042,
>    sin_addr = {   
>      s_addr = 859048458
>    }, 
>    sin_zero = "\000\000\000\000\000\000\000"
>  },   
>  xp_verf = {
>    oa_flavor = 0,
>    oa_base = 0x1b07280 "`",
>    oa_length = 0 
>  }, 
>  xp_p1 = 0x2a2eb00 "M\206",
>  xp_p2 = 0x1b07240 "`\"",
>  xp_pad = "\000002\000\000\000\000`\"\000\000\000\000\000\000\001\000\000\000\000\020\000\000\0000q\001\000\000\000\000\001\000\000\000\000\000\000\000xq\001\000\000\000\000 ", '\0' <repeats 11 times>
> , "\034", '\0' <repeats 11 times>, "\b\000\000\000\000\000\000\000\n\n4n\n4, '' <repeats 156 times>
> }
> 
> (gdb) set $x = rtnl
> (gdb) while ($x->next)
>> print $x->mon.mon_id.mon_name
>> set $x = $x->next  
>> end
> $4 = 0x1b07e80 "10.10.52.21"
> $5 = 0x2a2eab0 "10.10.52.23"
> $6 = 0x2a2e9b0 "10.10.52.31"
> $7 = 0x2b5b400 "10.10.52.18"
> $8 = 0x2a34080 "10.10.52.12"
> $9 = 0x1e63120 "10.10.52.30"
> $10 = 0x2a332e0 "10.10.52.24"
> $11 = 0x2a341e0 "10.10.52.50"
> $12 = 0x2357d00 "10.10.52.22"
> $13 = 0x1b07e60 "10.10.52.20"
> $14 = 0x2a33220 "10.10.52.18"
> $15 = 0x2a33170 "10.10.52.30"
> $16 = 0x21100d0 "10.10.52.20"  
> $17 = 0x2a32e10 "10.10.52.12"
> $18 = 0x2a33110 "10.10.52.29"
> $19 = 0x2a32e50 "10.10.52.25"
> $20 = 0x2110210 "10.10.52.30"
> $21 = 0x278b240 "10.10.52.25"
> $22 = 0x2a33820 "10.10.52.24"
> $23 = 0x1e63190 "10.10.52.30"
> $24 = 0x2406b60 "10.10.52.50"
> $25 = 0x29614f0 "10.10.52.50"
> $26 = 0x2406ab0 "10.10.52.25"
> $27 = 0x1b080a0 "10.10.52.29"
> $28 = 0x2256f00 "10.10.52.24"
> $29 = 0x2a2ea20 "10.10.52.22"
> $30 = 0x255e470 "10.10.52.19"
> $31 = 0x2a33b10 "10.10.52.28"
> $32 = 0x2a2e8f0 "10.10.52.31"
> $33 = 0x2a2e810 "10.10.52.31"
> $34 = 0x2a2e730 "10.10.52.31"
> $35 = 0x2a2e650 "10.10.52.31"
> $36 = 0x2a2e570 "10.10.52.31"
> $37 = 0x2a2e490 "10.10.52.31"
> $38 = 0x2a2e3b0 "10.10.52.31"
> $39 = 0x2a2e2d0 "10.10.52.31"
> $40 = 0x2a2e1f0 "10.10.52.31"
> $41 = 0x2a2e110 "10.10.52.31"
> $42 = 0x2a2e030 "10.10.52.31"
> $43 = 0x2a2df50 "10.10.52.31"
> $44 = 0x2a2de70 "10.10.52.31"  
> $45 = 0x2a2dd90 "10.10.52.31"
> $46 = 0x2a2dcb0 "10.10.52.31"
> $47 = 0x2a2dbd0 "10.10.52.31"
> $48 = 0x2a2daf0 "10.10.52.31"
> $49 = 0x2a2da10 "10.10.52.31"
> $50 = 0x2a2d930 "10.10.52.31"  
> ...
> $6949 = 0x28b42d0 "10.10.52.30"
> $6950 = 0x28b41f0 "10.10.52.30"
> ...
> $14429 = 0x271b010 "10.10.52.22"
> $14430 = 0x271af30 "10.10.52.22"
> ...
> $24804 = 0x24e3590 "10.10.52.25"
> $24805 = 0x24e34b0 "10.10.52.25"
> ...
> $28179 = 0x242ac70 "10.10.52.19"
> $28180 = 0x242ab90 "10.10.52.19"
> ...
> $44671 = 0x20a46f0 "10.10.52.20"
> $44672 = 0x20a4610 "10.10.52.20"
> 
> Hmm, I think that list got a little longer than expected. What would be
> causing this?

See above... statd is not supposed to allow duplicates in this list, so there is probably some kind of logic error that is preventing it from finding these duplicates when they appear.  One cause might be duplicate on-disk monitor records that are read in at start-up time, and never deleted by sm-notify for some reason.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




