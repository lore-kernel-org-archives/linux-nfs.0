From: John Frisk <john_a_frisk@yahoo.com>
Subject: Re: NFS hang in 2.6.21.1
Date: Mon, 21 May 2007 11:37:10 -0700 (PDT)
Message-ID: <174023.84136.qm@web54407.mail.yahoo.com>
References: <1179766574.6737.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqCks-00074V-Fl
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 11:37:14 -0700
Received: from web54407.mail.yahoo.com ([206.190.49.137])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HqCku-0001EL-3k
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 11:37:17 -0700
In-Reply-To: <1179766574.6737.25.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Trond,
I applied your patches to both kernels, rebooted and
still the same problem.  Once bonnie attempts to
"rewrite" it's sample file, the client machine process
cannot be killed.  The client OS however can still do
other things, such as load firefox, etc.  The
interesting thing being, it can also in another shell
access the same directory under NFS as the bonnie
program was writing in the other shell.  Sorry for not
knowing all the internals, but is the NFS client
multi-threaded too?

Output:
jfrisk@evil:~$ /usr/sbin/bonnie++ -f -s 100 -n 1 -r 0
Writing intelligently...done
Rewriting...

jfrisk@evil:~$ ps axu | grep bonnie
jfrisk    5612  0.2  0.0   2708  1012 pts/2    D+  
13:24   0:01 /usr/sbin/bonnie++ -f -s 100 -n 1 -r 0

What should I do next?  Should I capture some of the
tcpdump output or compile debugging or profiling into
the kernel for evaluation?

Thanks!

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> On Mon, 2007-05-21 at 07:18 -0700, John Frisk wrote:
> > Team,
> > I have been attempting to put together a linux HA
> NFS
> > server for my home environment.  I am currently
> > running two Debian etch 4.0 machines both running
> > vanilla 2.6.21.1 kernels that I compiled
> (exception
> > being the nvidia driver for video).  When I
> attempt to
> > do some performance benchmarks, a test of bonnie++
> > makes the NFS client stuck in a non-responsive
> > non-killable state.  The NFS server at this point
> is
> > not busy doing anything so I believe there may be
> some
> > condition leading to a deadlock in the client. 
> 
> Could you please try the patches
> 
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-002-no_congestion_wait_in_update_request.dif
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-003-cleanup_coalesce.dif
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-004-cleanup_coalesce2.dif
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-005-cleanup_readpages.dif
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-006-fix_dirtying_race.dif
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-007-fix_page_overflow.dif
> 
> and
> 
>
http://client.linux-nfs.org/Linux-2.6.x/2.6.22-rc2/linux-2.6.22-001-write_deadlock_avoidance.dif
> 
> That fixes all the write deadlock issues for me.
> 
> Trond
> 
> 



       
____________________________________________________________________________________Ready for the edge of your seat? 
Check out tonight's top picks on Yahoo! TV. 
http://tv.yahoo.com/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
