From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd shutdown/umount order
Date: 28 Jan 2003 19:01:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbs21b1ch.fsf@charged.uio.no>
References: <20030128150524.E11078@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030128150524.E11078@blackjesus.async.com.br>
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

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

     > As the final cleanup of the diskless shutdown sequence, I would
     > like to know what procedure is the correct one for an NFS-root
     > workstation.  Currently, the following set of steps happens:

     > 1. killall5 murders rpc.statd and portmap
     > 2. umount -tnfs -a -r runs
     > 3. the kernel complains:
     >         lockd_down: lockd failed to exit, clearing pid
     > 4. halt goes on without a problem.
     > 5. lockd complains: failed to unmonitor 192.168.99.4 *after
     >        halt*

killall5 sucks as a method for shutting down processes. It is far too
unselective.

The above messages mean that you still had a byte-range lock being
held when statd got killed. When the process that held the lock got
killed, the kernel automatically tried to release the lock, but failed
to notify statd that it had done so 'cos statd and portmap were no
longer running.

Make sure that you kill those other processes *before* you kill statd
and portmap.


Note: if you want to be clever about this, it is possible to divine
the pids of the processes that are holding locks (at least in the case
of POSIX locks which are the interesting ones here) by doing something
like
    awk '/POSIX/ { print $5; }' </proc/locks

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
