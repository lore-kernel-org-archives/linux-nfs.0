From: Christian Reis <kiko@async.com.br>
Subject: Re: lockd shutdown/umount order
Date: Tue, 28 Jan 2003 19:38:54 -0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030128193854.B11568@blackjesus.async.com.br>
References: <20030128150524.E11078@blackjesus.async.com.br> <shsbs21b1ch.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsbs21b1ch.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Jan 28, 2003 at 07:01:18PM +0100
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

On Tue, Jan 28, 2003 at 07:01:18PM +0100, Trond Myklebust wrote:
> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > As the final cleanup of the diskless shutdown sequence, I would
>      > like to know what procedure is the correct one for an NFS-root
>      > workstation.  Currently, the following set of steps happens:
> 
>      > 1. killall5 murders rpc.statd and portmap
>      > 2. umount -tnfs -a -r runs
>      > 3. the kernel complains:
>      >         lockd_down: lockd failed to exit, clearing pid
>      > 4. halt goes on without a problem.
>      > 5. lockd complains: failed to unmonitor 192.168.99.4 *after
>      >        halt*
> 
> killall5 sucks as a method for shutting down processes. It is far too
> unselective.

Agreed. The patch will go upstream to Miquel to see if we can at least
get basic selectivity (-o pid to omit, multiple allowed).

> The above messages mean that you still had a byte-range lock being
> held when statd got killed. When the process that held the lock got
> killed, the kernel automatically tried to release the lock, but failed
> to notify statd that it had done so 'cos statd and portmap were no
> longer running.

Well, I put a cat /proc/locks just before the killall5 and no locks are
being held (or none are being shown at least), so I don't think that is
the issue. Could it be that lockd is not going down, even after all
locks are released? 

How *should* be lockd killed, actually? It doesn't seem to care about
signals we send, does it?

> Make sure that you kill those other processes *before* you kill statd
> and portmap.

But none of them *are* running, no locks show up, and no special processes
seem to appear on ps ax output:

      PID TTY      STAT   TIME COMMAND
        1 ?        S      0:03 init
        2 ?        SW     0:00 [keventd]
        3 ?        SWN    0:00 [ksoftirqd_CPU0]
        4 ?        SW     0:00 [kswapd]
        5 ?        SW     0:00 [bdflush]
        6 ?        SW     0:00 [kupdated]
        7 ?        SW     0:00 [eth0]
        8 ?        SW     0:00 [rpciod]
       90 ?        S      0:00 /sbin/portmap
      106 ?        S      0:00 /sbin/rpc.statd
      112 ?        SW     0:00 [lockd]
      166 ?        S      0:00 /sbin/klogd
      509 ?        S      0:00 /bin/sh /etc/init.d/rc 0
      600 ?        S      0:00 /bin/sh /etc/rc0.d/S29sendsigs stop
      607 ?        R      0:00 ps ax

What could it be?

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
