From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: NFS Locking Issue - Solaris-Linux
Date: Fri, 25 Oct 2002 12:53:52 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210251753.g9PHrqu01095@leinie.lmcg.wisc.edu>
References: <3DB55BCC.447F0C32@neolinear.com> <200210221602.g9MG2BS25573@leinie.lmcg.wisc.edu> <3DB6EFF8.D8B659B0@neolinear.com>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Cc: nfs@lists.sourceforge.net, it@neolinear.com, support@raidzone.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1858eh-0007xb-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 10:53:55 -0700
To: Bill Schrier <wschrier@neolinear.com>
In-reply-to: <3DB6EFF8.D8B659B0@neolinear.com> (message from Bill Schrier on
	Wed, 23 Oct 2002 14:52:40 -0400)
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

>> Thanks for the input - it is dead on.  We tested your work around,
>> and it worked exactly as you described.

I'm actually glad that someone else saw this same bug.

>> The one thing that confuses me is that Raidzone said that they were
>> unable to reproduce the error - but you said you thought that
>> disabling nlockmgr over TCP was a compile time option.  If this is
>> the case, then I would assume that Raidzone would also be running
>> with nlockmgr over TCP - since I think we are running the same
>> kernel that they are.

After I downgraded to 2.4.16-10, I upgraded another (non-Raidzone)
machine to 2.4.18 and figured I could continue my testing.  Bzzzzt.
Everything worked fine with NLM over TCP.  I am suspecting that not
only is it a timing related bug, it is probably a hardware specific
bug, and maybe even limited to only a subset of the Raidzone boxes if
they can't reproduce the error themselves.  Otherwise they should have
complaints from lots of Sun users, right?

>> Does anyone know if this is indeed correct?  Is there a way to
>> disable nlockmgr over TCP without a kernel recompile?

I would be interested in this too in case I run into it again.

>> We're not too interested in downrevving our kernel on this machine.
>> Since a stock Redhat install appears to come with nlockmgr disabled
>> on TCP by default, it seems that it got turned on somewhere along
>> the way with the Raidzone kernel distributions, and really needs to
>> be turned back off - especially in an environment with Solaris
>> clients.

If you turn on NFS over TCP you get NLM over TCP.  I assume they are
turning on NFS over TCP for performance reasons.

-- 
+----------------------------------+----------------------------------+
| Daniel K. Forrest                | Laboratory for Molecular and     |
| forrest@lmcg.wisc.edu            | Computational Genomics           |
| (608)262-9479                    | University of Wisconsin, Madison |
+----------------------------------+----------------------------------+


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
