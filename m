From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: NFS Locking Issue - Solaris-Linux
Date: Tue, 22 Oct 2002 11:02:11 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210221602.g9MG2BS25573@leinie.lmcg.wisc.edu>
References: <3DB55BCC.447F0C32@neolinear.com>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Cc: nfs@lists.sourceforge.net, it@neolinear.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1841Tx-0005A4-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 09:02:13 -0700
To: Bill Schrier <wschrier@neolinear.com>
In-reply-to: <3DB55BCC.447F0C32@neolinear.com> (message from Bill Schrier on
	Tue, 22 Oct 2002 10:08:12 -0400)
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

Bill,

>> We've been having a bit of trouble finding a solution to a problem
>> we've been having between our Solaris machines and our Raidzone
>> machine running Redhat (kernel 2.4.18-12smp).  I would appreciate
>> any input on this subject as it is basically keeping us from
>> effectively using the storage space we have in the Raidzone box.
>> 
>> The problem arises when we try to lock any file shared from the
>> Redhat machine from any of our Solaris machines.  This happens
>> regardless of the Solaris kernel version - 2.6, 8, and multiple
>> kernel patch levels within those OS versions.  However, with a
>> clean install of Redhat, we are able to successfully lock shared
>> files - it is just this Raidzone machine.

What is the mode of failure?  Does the lock request just hang?  I may
have seen this same problem (it was on a Raidzone under 2.4.18-10smp)
and can offer some insight.

Is the Raidzone offering lock service over TCP?  Run "rpcinfo -p" on
the Raidzone to find out.

If it is, note the port number "nlockmgr" is using.  Now, while one of
the Solaris machines is trying to lock a file, run "netstat --ip" on
the Raidzone and look for that port number.  Are bytes accumulating in
the "Recv-Q" for that port?  When I saw this problem I would see 192
bytes (the size of a lock request) show up every 30 seconds.

If this is the case, now do an "echo 256 > /proc/sys/sunrpc/rpc_debug"
(0x0100 hex which is RPCDBG_SVCSOCK) on the Raidzone and wait for the
next lock request to arrive.  If it is the same problem I saw, the
"Recv-Q" will empty at this time and the lock request will succeed.

At this point, even if "/proc/sys/sunrpc/rpc_debug" is restored to 0,
all lock requests from the Solaris machine will succeed as long as the
"nlockmgr" connection remains "ESTABLISHED".  If the connection is
dropped (occurs after 5 minutes of inactivity) and has to be remade
the same problem occurs.

There is obviously some sort of timing related bug going on here, but
I have no idea what it is.  I discovered the "rpc_debug" trick while
trying to diagnose the problem.  The first time I set all of the bits
in "rpc_debug" things suddenly started to work.  I then tried setting
single bits until I found that "RPCDBG_SVCSOCK" did the trick.

Obviously, leaving the debug turned on is no solution because the
messages file will grow out of control and performance will suffer.

My solution was to downgrade the kernel to 2.4.16-10smp (which does
not offer "nlockmgr" over TCP) and everything works fine.  I don't
know if it is possible to disable "nlockmgr" over TCP on 2.4.18-10smp,
I think it is a compile time option.  I suppose you could edit the
output from pmap_dump and then use pmap_set to unregister it.

I would be interested to know if these are the same symptoms you are
seeing and if the "rpc_debug" trick works for you.  I would also be
interested in knowing if Raidzone finds a fix for this.  Once I got
things working again under 2.4.16-10smp I never found the time to
pursue it any further.

-- 
+----------------------------------+----------------------------------+
| Daniel K. Forrest                | Laboratory for Molecular and     |
| forrest@lmcg.wisc.edu            | Computational Genomics           |
| (608)262-9479                    | University of Wisconsin, Madison |
+----------------------------------+----------------------------------+


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
