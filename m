From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Tue, 3 Jan 2006 14:01:39 -0500
Message-ID: <20060103190138.GA6782@tau.solarneutrino.net>
References: <20051217055907.GC20539@tau.solarneutrino.net> <1134801822.7946.4.camel@lade.trondhjem.org> <20051217070222.GD20539@tau.solarneutrino.net> <1134847699.7950.25.camel@lade.trondhjem.org> <20051217194553.GE20539@tau.solarneutrino.net> <1134894836.7931.17.camel@lade.trondhjem.org> <20051218180150.GF20539@tau.solarneutrino.net> <1134934267.7966.37.camel@lade.trondhjem.org> <20051218200052.GA21665@tau.solarneutrino.net> <1134944665.11596.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	ryan@tau.solarneutrino.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Etrmv-0005uQ-9k
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 11:25:41 -0800
Received: from solarneutrino.net ([66.199.224.43] helo=tau.solarneutrino.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Etrmt-0003z5-SR
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 11:25:41 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134944665.11596.9.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Sun, Dec 18, 2005 at 05:24:24PM -0500, Trond Myklebust wrote:
> On Sun, 2005-12-18 at 15:00 -0500, Ryan Richter wrote:
> > On Sun, Dec 18, 2005 at 02:31:07PM -0500, Trond Myklebust wrote:
> > > On Sun, 2005-12-18 at 13:01 -0500, Ryan Richter wrote:
> > > > Code: 48 39 78 18 75 1c 8b 86 8c 00 00 00 a8 01 74 12 83 c8 02 89 
> > > > RIP <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62} RSP <ffff81007dfade70>
> > > > CR2: 0000000000000018
> > > 
> > > Looks like the global lock list is corrupted. Could you cat the contents
> > > of /proc/locks?
> > 
> > $ cat /proc/locks
> > 1: POSIX  ADVISORY  WRITE 1657 00:0e:1771273 0 EOF
> > 2: FLOCK  ADVISORY  WRITE 1486 00:0e:1770759 0 EOF
> > 3: FLOCK  ADVISORY  WRITE 1478 00:0e:1770399 0 EOF
> 
> OK. I think this client patch ought to fix the Oopses. It should apply
> to a 2.6.14 kernel as well as 2.6.15-rc5.

I applied this patch to 2.6.14.3 and booted it before I left in
December.  Now that I'm back, I see that the problem has returned -
lockd is no longer running, and

general protection fault: 0000 [1] 
CPU 0 
Modules linked in:
Pid: 1174, comm: lockd Not tainted 2.6.14.3 #1
RIP: 0010:[<ffffffff801dbda3>] <ffffffff801dbda3>{nlmclnt_mark_reclaim+67}
RSP: 0018:ffff81007dfade70  EFLAGS: 00010206
RAX: 3168647300000000 RBX: ffff81007ec1cb40 RCX: ffffffff803e4650
RDX: ffff81007f31b0a0 RSI: ffff81007f31b098 RDI: ffff81007ec1cb40
RBP: ffff81000327e200 R08: 00000000fffffffa R09: 0000000000000001
R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: ffffffff803ec460 R15: ffff81007df5f014
FS:  00002aaaab00c4a0(0000) GS:ffffffff804b6800(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000512000 CR3: 000000007c8d0000 CR4: 00000000000006e0
Process lockd (pid: 1174, threadinfo ffff81007dfac000, task ffff81007eea61c0)
Stack: ffffffff801dbe6b ffff81007ec1cb40 ffffffff801e3d8c 3256cc8445030002 
       0000000000000000 ffff81007df5bc68 ffff81007df5bc00 ffffffff803ed4e0 
       ffff81007df5bca0 ffff81007df5bc68 
Call Trace:<ffffffff801dbe6b>{nlmclnt_recovery+139} <ffffffff801e3d8c>{nlm4svc_proc_sm_notify+188}
       <ffffffff8034c5e4>{svc_process+884} <ffffffff8012ab40>{default_wake_function+0}
       <ffffffff801dde00>{lockd+352} <ffffffff801ddca0>{lockd+0}
       <ffffffff8010e352>{child_rip+8} <ffffffff801ddca0>{lockd+0}
       <ffffffff801ddca0>{lockd+0} <ffffffff8010e34a>{child_rip+0}
       

Code: 48 39 78 18 75 17 8b 86 8c 00 00 00 a8 01 74 0d 83 c8 02 89 
RIP <ffffffff801dbda3>{nlmclnt_mark_reclaim+67} RSP <ffff81007dfade70>

-ryan


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
