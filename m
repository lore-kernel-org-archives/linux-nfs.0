From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: Re: NFSv3 blocking locks broken in 2.6.7
Date: Wed, 18 Aug 2004 14:30:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF1E311F0C.DE07BF39-ON88256EF4.0074E199-88256EF4.0076294E@us.ibm.com>
References: <1092848539.4931.56.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1092848539.4931.56.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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





Hi Trond,

I tried the changed that you recommended on the NFS client but it did not
help. Following is an NLM trace on the NFS server that shows the problem.
Tracing the code points to a problem that is marked below with '*****'

Thanks, Marc.
-----------------------------------------------------------------------------------------------------
1. Local lock with fcntl(fd, F_SETLK, 1-5)

2. Lock from NFS client with fcntl(fd, F_SELKW, 1-5) - blocked

Aug 18 13:49:00 lockd: request from 09014042
Aug 18 13:49:00 lockd: LOCK          called
Aug 18 13:49:00 lockd: nlm_lookup_host(09014042, p=17, v=4)
Aug 18 13:49:00 lockd: host garbage collection
Aug 18 13:49:00 lockd: nlmsvc_mark_resources
Aug 18 13:49:00 nlm_gc_hosts skipping 9.1.64.66 (cnt 0 use 0 exp 3784570)
Aug 18 13:49:00 lockd: delete host 9.1.64.66
Aug 18 13:49:00 lockd: get host 9.1.64.66
Aug 18 13:49:00 lockd: nlm_file_lookup(02000001 03000300 0006fc81 00070d65
7c32bc32 0006fc81)
Aug 18 13:49:00 lockd: found file c1584c00 (count 1)
Aug 18 13:49:00 lockd: nlmsvc_lock(hda3/462181, ty=1, pi=1380, 1-5, bl=1)
Aug 18 13:49:00 lockd: nlmsvc_lookup_block f=c1584c00 pd=1380 1-5 ty=1
Aug 18 13:49:00 lockd: blocking on this lock (allocating).
Aug 18 13:49:00 lockd: nlm_lookup_host(09014042, p=17, v=4)
Aug 18 13:49:01 lockd: creating host entry
Aug 18 13:49:02 lockd: created block d8d5e000...
Aug 18 13:49:03 lockd: nlmsvc_insert_block(d8d5e000, -1)
Aug 18 13:49:03 lockd: blocking on this lock.
Aug 18 13:49:04 lockd: LOCK          status 3
Aug 18 13:49:04 lockd: release host 9.1.64.66
Aug 18 13:49:05 lockd: nlm_release_file(c1584c00, ct = 2)
Aug 18 13:49:05 nlmsvc_retry_blocked(d8d5e000, when=-1)
Aug 18 13:49:05 nlmsvc_retry_blocked(d8d5e000, when=-1)

3. Release local lock with fcntl(fd, F_UNLCK, 1-5)

4. NFS lock granted

Aug 18 13:49:30 lockd: request from 09014042
Aug 18 13:49:30 lockd: LOCK          called
Aug 18 13:49:30 lockd: nlm_lookup_host(09014042, p=17, v=4)
Aug 18 13:49:30 lockd: get host 9.1.64.66
Aug 18 13:49:30 lockd: nlm_file_lookup(02000001 03000300 0006fc81 00070d65
7c32bc32 0006fc81)
Aug 18 13:49:30 lockd: found file c1584c00 (count 1)
Aug 18 13:49:30 lockd: nlmsvc_lock(hda3/462181, ty=1, pi=1380, 1-5, bl=1)
Aug 18 13:49:30 lockd: nlmsvc_lookup_block f=c1584c00 pd=1380 1-5 ty=1
Aug 18 13:49:30 lockd: check f=c1584c00 pd=1380 1-5 ty=1 cookie=123d
Aug 18 13:49:30 lockd: nlmsvc_insert_block(d8d5e000, -1)
Aug 18 13:49:30 lockd: LOCK          status 3
Aug 18 13:49:30 lockd: release host 9.1.64.66
Aug 18 13:49:30 lockd: nlm_release_file(c1584c00, ct = 2)
Aug 18 13:49:37 nlmsvc_retry_blocked(d8d5e000, when=-1)
Aug 18 13:49:37 nlmsvc_retry_blocked(d8d5e000, when=-1)
Aug 18 13:49:38 lockd: VFS unblock notification for block d8d5e0b0
Aug 18 13:49:39 lockd: nlmsvc_insert_block(d8d5e000, 0)
Aug 18 13:49:39 nlmsvc_retry_blocked(d8d5e000, when=3799958)
Aug 18 13:49:40 nlmsvc_retry_blocked(d8d5e000, when=3799958, done=0)
Aug 18 13:49:42 lockd: grant blocked lock d8d5e000
Aug 18 13:49:43 lockd: GRANTing blocked lock.
Aug 18 13:49:44 lockd: nlmsvc_insert_block(d8d5e000, 30000)
Aug 18 13:49:45 lockd: get host 9.1.64.66
Aug 18 13:49:47 lockd: call procedure 10 on 9.1.64.66 (async)
Aug 18 13:49:48 lockd: nlm_bind_host(09014042)
Aug 18 13:49:49 lockd: GRANT_MSG RPC callback
Aug 18 13:49:50 callback: looking for cookie 123d, host (09014042)
Aug 18 13:49:50 cookie: head of blocked queue d8d5e000, block d8d5e000
Aug 18 13:49:52 lockd: nlmsvc_insert_block(d8d5e000, 60000)
Aug 18 13:49:53 lockd: release host 9.1.64.66
Aug 18 13:49:54 lockd: request from 09014042
Aug 18 13:49:55 lockd: GRANTED_RES   called
Aug 18 13:49:55 grant_reply: looking for cookie 123d, host (09014042), s=0
Aug 18 13:49:56 cookie: head of blocked queue d8d5e000, block d8d5e000
Aug 18 13:49:57 cookie: head of blocked queue d8d5e000, block d8d5e000
Aug 18 13:49:57 lockd: deleting block d8d5e000...

***** This appears to be the problem. posix_unblock_lock called from
nlmsvc_delete_block
***** with waiter->fl_next NULL resulting in call to posix_lock_file(UNLCK)
which
***** releases the lock on the server.
Code from 2.6.8.1: fs/locks.c

void
posix_unblock_lock(struct file *filp, struct file_lock *waiter)
{
 /*
  * A remote machine may cancel the lock request after it's been
  * granted locally.  If that happens, we need to delete the lock.
  */
 lock_kernel();
 if (waiter->fl_next) {
  __locks_delete_block(waiter);
  unlock_kernel();
 } else {
  unlock_kernel();
  waiter->fl_type = F_UNLCK;
  posix_lock_file(filp, waiter);             <<<<******
 }
}

Aug 18 13:49:58 lockd: release host 9.1.64.66
Aug 18 13:49:59 lockd: nlm_release_file(c1584c00, ct = 3)
Aug 18 13:50:01 nlmsvc_retry_blocked(00000000, when=0)
Aug 18 13:50:06 nlmsvc_retry_blocked(00000000, when=0)


5. Release NFS lock. (At this point, lock has already been released on
server).

Aug 18 13:51:41 lockd: request from 09014042
Aug 18 13:51:41 lockd: UNLOCK        called
Aug 18 13:51:41 lockd: nlm_lookup_host(09014042, p=17, v=4)
Aug 18 13:51:41 lockd: host garbage collection
Aug 18 13:51:41 lockd: nlmsvc_mark_resources
Aug 18 13:51:41 lockd: delete host 9.1.64.66
Aug 18 13:51:41 lockd: nsm_unmonitor(9.1.64.66)
Aug 18 13:51:41 lockd: delete host 9.1.64.66
Aug 18 13:51:41 lockd: creating host entry
Aug 18 13:51:41 lockd: nlm_file_lookup(02000001 03000300 0006fc81 00070d65
7c32bc32 0006fc81)
Aug 18 13:51:41 lockd: found file c1584c00 (count 2)
Aug 18 13:51:41 lockd: nlmsvc_unlock(hda3/462181, pi=1380,
0-9223372036854775807)
Aug 18 13:51:41 lockd: nlmsvc_cancel(hda3/462181, pi=1380,
0-9223372036854775807)
Aug 18 13:51:41 lockd: nlmsvc_lookup_block f=c1584c00 pd=1380
0-9223372036854775807 ty=2
Aug 18 13:51:41 lockd: UNLOCK        status 0
Aug 18 13:51:41 lockd: release host 9.1.64.66
Aug 18 13:51:41 lockd: nlm_release_file(c1584c00, ct = 3)
Aug 18 13:51:41 nlmsvc_retry_blocked(00000000, when=0)




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
