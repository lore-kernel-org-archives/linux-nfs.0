From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: processes stuck in D state
Date: Tue, 6 May 2003 18:05:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16055.56630.615496.19679@charged.uio.no>
References: <200305061652.13280.fsdeveloper@yahoo.de>
	<shsel3c85ks.fsf@charged.uio.no>
	<200305061742.14032.fsdeveloper@yahoo.de>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net,
    "Lever, Charles" <Charles.Lever@netapp.com>,
    linux kernel mailing list <linux-kernel@vger.kernel.org>,
    Zeev Fisher <Zeev.Fisher@il.marvell.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D4wl-0005if-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 09:05:40 -0700
To: Michael Buesch <fsdeveloper@yahoo.de>
In-Reply-To: <200305061742.14032.fsdeveloper@yahoo.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Michael Buesch <fsdeveloper@yahoo.de> writes:


     > To reproduce the problem:
     > - - mount some nfs from a server in your lan.
     > - - Open an app, that uses the mounted fs. I've simply opened a
     >   konqueror-window for the directory where the nfs is mounted.
     > - - shut down or crash the server or just pull the
     >     network-cable.
     > - - Now the konqueror-process is nonkillable in D
     >     state. There's no
     >   chance to kill it.

Unless you are using the 'intr' or 'soft' mount flags, then that is
*documented and expected* behaviour.

It is true that even when using the 'intr' mount flag, you don't
always succeed in killing a task that is hanging on NFS. That is
usually due to the fact that it is waiting on some semaphore that is
held by another process. semaphores always sleep in the
TASK_UNINTERRUPTIBLE state, so they cannot be signalled.
Linus has suggested a solution to this problem: to set up a special
class of semaphores that are killable with 'SIGKILL', but doing that
(and then replacing all those semaphores in the VFS and VM) is not
going to happen before 2.7.x. at the earliest.

However, as I've mentioned on this list *many* times before: there
exists a workaround if you are wanting to kill all processes in order
to unmount the partition:
  kill -9 all the processes.
  kill -9 rpciod.

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
