From: Bill Schrier <wschrier@neolinear.com>
Subject: Re: NFS Locking Issue - Solaris-Linux
Date: Wed, 23 Oct 2002 14:52:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB6EFF8.D8B659B0@neolinear.com>
References: <3DB55BCC.447F0C32@neolinear.com> <200210221602.g9MG2BS25573@leinie.lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, it@neolinear.com,
 	support@raidzone.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184Qe7-0005VC-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 11:54:23 -0700
To: Daniel Forrest <forrest@lmcg.wisc.edu>
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

Daniel,

Thanks for the input - it is dead on.  We tested your work around, and it
worked exactly as you described.

The one thing that confuses me is that Raidzone said that they were unable
to reproduce the error - but you said you thought that disabling nlockmgr
over TCP was a compile time option.  If this is the case, then I would
assume that Raidzone would also be running with nlockmgr over TCP - since
I think we are running the same kernel that they are.

Does anyone know if this is indeed correct?  Is there a way to disable
nlockmgr over TCP without a kernel recompile?

We're not too interested in downrevving our kernel on this machine.  Since
a stock Redhat install appears to come with nlockmgr disabled on TCP by
default, it seems that it got turned on somewhere along the way with the
Raidzone kernel distributions, and really needs to be turned back off -
especially in an environment with Solaris clients.

Again, any further information is greatly appreciated.

Thanks!

Bill

Daniel Forrest wrote:

> Bill,
>
> >> We've been having a bit of trouble finding a solution to a problem
> >> we've been having between our Solaris machines and our Raidzone
> >> machine running Redhat (kernel 2.4.18-12smp).  I would appreciate
> >> any input on this subject as it is basically keeping us from
> >> effectively using the storage space we have in the Raidzone box.
> >>
> >> The problem arises when we try to lock any file shared from the
> >> Redhat machine from any of our Solaris machines.  This happens
> >> regardless of the Solaris kernel version - 2.6, 8, and multiple
> >> kernel patch levels within those OS versions.  However, with a
> >> clean install of Redhat, we are able to successfully lock shared
> >> files - it is just this Raidzone machine.
>
> What is the mode of failure?  Does the lock request just hang?  I may
> have seen this same problem (it was on a Raidzone under 2.4.18-10smp)
> and can offer some insight.
>
> Is the Raidzone offering lock service over TCP?  Run "rpcinfo -p" on
> the Raidzone to find out.
>
> If it is, note the port number "nlockmgr" is using.  Now, while one of
> the Solaris machines is trying to lock a file, run "netstat --ip" on
> the Raidzone and look for that port number.  Are bytes accumulating in
> the "Recv-Q" for that port?  When I saw this problem I would see 192
> bytes (the size of a lock request) show up every 30 seconds.
>
> If this is the case, now do an "echo 256 > /proc/sys/sunrpc/rpc_debug"
> (0x0100 hex which is RPCDBG_SVCSOCK) on the Raidzone and wait for the
> next lock request to arrive.  If it is the same problem I saw, the
> "Recv-Q" will empty at this time and the lock request will succeed.
>
> At this point, even if "/proc/sys/sunrpc/rpc_debug" is restored to 0,
> all lock requests from the Solaris machine will succeed as long as the
> "nlockmgr" connection remains "ESTABLISHED".  If the connection is
> dropped (occurs after 5 minutes of inactivity) and has to be remade
> the same problem occurs.
>
> There is obviously some sort of timing related bug going on here, but
> I have no idea what it is.  I discovered the "rpc_debug" trick while
> trying to diagnose the problem.  The first time I set all of the bits
> in "rpc_debug" things suddenly started to work.  I then tried setting
> single bits until I found that "RPCDBG_SVCSOCK" did the trick.
>
> Obviously, leaving the debug turned on is no solution because the
> messages file will grow out of control and performance will suffer.
>
> My solution was to downgrade the kernel to 2.4.16-10smp (which does
> not offer "nlockmgr" over TCP) and everything works fine.  I don't
> know if it is possible to disable "nlockmgr" over TCP on 2.4.18-10smp,
> I think it is a compile time option.  I suppose you could edit the
> output from pmap_dump and then use pmap_set to unregister it.
>
> I would be interested to know if these are the same symptoms you are
> seeing and if the "rpc_debug" trick works for you.  I would also be
> interested in knowing if Raidzone finds a fix for this.  Once I got
> things working again under 2.4.16-10smp I never found the time to
> pursue it any further.
>
> --
> +----------------------------------+----------------------------------+
> | Daniel K. Forrest                | Laboratory for Molecular and     |
> | forrest@lmcg.wisc.edu            | Computational Genomics           |
> | (608)262-9479                    | University of Wisconsin, Madison |
> +----------------------------------+----------------------------------+

--
William J. Schrier              Phone: 412.968.5780 x151
Neolinear, Inc.                 Fax:   412.968.5788
583 Epsilon Drive               Email: wschrier@neolinear.com
Pittsburgh, PA  15238





-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
