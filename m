From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Isolation of nfs threads
Date: Thu, 19 Sep 2002 21:32:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15753.46523.847227.539366@notabene.cse.unsw.edu.au>
References: <005401c25fa4$6c6a8270$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rzY2-0000j0-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 04:32:42 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <kedar@calsoftinc.com>) (for <nfs@lists.sourceforge.net>)
	(for <rusty@rustcorp.com.au>) By tone With Smtp ;
	Thu, 19 Sep 2002 21:32:19 +1000
To: "Kedar Sovani" <kedar@calsoftinc.com>
In-Reply-To: message from Kedar Sovani on Thursday September 19
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

On Thursday September 19, kedar@calsoftinc.com wrote:
> Hey,
>       I am resending this message, can anyone please comment about the problem stated below.
> 
>         How does nfs maintain the isolation between multiple 
> threads.That is when one nfs thread is running how does it avoid other 
> nfs threads from running. This is achieved in BSD using the splxxx() 
> functions. But in LINUX i do not see any similare function which handles
> this.
>         Or more generally how does the LINUX kernel, lower and raise the 
> interrupt level it is currently working on? How does it apply to NFS ?

spinlocks mostly, and semaphores.

look for "lock_kernel" and "unlock_kernel" which is a specialised sort
of lock that is released when the process "schedules", and gives
another process a turn at the cpu, and is then automatically claimed
again when the process gets another turn.

The nfsd code in 2.4 mostly depends on the this lock.

The network and rpc bits use spinlock (spin_lock, spin_unlock).

The nfsd code in 2.5 uses a semaphore (up/down) and some spinlocks to
avoid needing lock_kernel (also known as the Big Kernel Lock).

It is probably worth reading Rusty's unreliable guide to kernel
locking. See the bottom of:

   http://www.netfilter.org/unreliable-guides/

The html link seems to be broken... Rusty???

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
