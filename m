From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 11:23:43 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C98D3AF.8091F420@amis.com>
References: <3C88F8EE.86058BD5@sls.lcs.mit.edu>
		<shs7kollatu.fsf@charged.uio.no>
		<3C98AD4B.8244EDC0@sls.lcs.mit.edu>
		<15512.44669.95177.801025@charged.uio.no> <15512.44969.304675.703836@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: I Lee Hetherington <ilh@sls.lcs.mit.edu>,
 	nfs@lists.sourceforge.net
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nkkc-0002Uh-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 10:23:54 -0800
To: trond.myklebust@fys.uio.no
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

Trond,

Some more data from some 2.4.18 tests I just ran...

==FIRST TEST

CLIENT: CLEAN 2.4.18 kernel with NFSV3 enabled 
SERVER: Solaris 8 server (E280R)

100M switched network (1G backbone connecting these two boxes -- but
results the same when staying on local switch)


Writing with putc()...         done:   5941 kB/s  59.3 %CPU
Rewriting...                   done:   5254 kB/s   6.7 %CPU
Writing intelligently...       done:   5605 kB/s   4.1 %CPU
Reading with getc()...         done:   9028 kB/s  89.3 %CPU
Reading intelligently...       done: 197558 kB/s 100.3 %CPU

==SECOND TEST
CLIENT: Same setup as the first but with linux-2.4.18-NFS_ALL.dif
applied. Same .config file.
SERVER: Same

Writing with putc()...         done:   5977 kB/s  63.5 %CPU
Rewriting...                   done:   3494 kB/s   5.7 %CPU
Writing intelligently...       done:    734 kB/s   0.7 %CPU
Reading with getc()...         done:   9255 kB/s  72.8 %CPU
Reading intelligently...       done: 195361 kB/s  34.3 %CPU


PROBLEM: the intelligent writes look bad.

==THIRD TEST
Same setup as second test, but using dd instead of bonnie

mohawk/test> time dd if=/dev/zero of=file bs=1024k count=1
1+0 records in
1+0 records out
0.000u 0.030s 0:05.06 0.5%      0+0k 0+0io 136pf+0w

About 200k/s on a 100Mbit network -- not very good.

I grabbed a simple tcpdump of that whole dd session.  I'll send a
off-list copy of the dump to Trond.

eric




Trond Myklebust wrote:
> 
> >>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
>      > exceeded' ICMP messages littered around the place. The first
>      > one comes just after the loss of fragments, and is accompanied
>      > by a 2 second delay, during which all the reads that are sent
>      > time out without receiving a single reply...
> 
> Note: this 2 second period of silence appears to be what is really
> causing the *100 slowdown. I've no idea what the switch is engaging in
> during that time, but you might want to take a look to see if those
> messages being sent during that period are indeed being received on
> the server.
> 
> Cheers,
>   Trond
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
