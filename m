From: Dan Kegel <dkegel@ixiacom.com>
Subject: rpc.rexd source for Linux?
Date: Fri, 18 Jul 2003 08:00:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15FDCE057B48784C80836803AE3598D53B8CDB@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 64-60-75-69.cust.telepacific.net ([64.60.75.69] helo=racerx.ixiacom.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dWht-0007zG-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 07:59:37 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

I fondly remember using 'on' to execute programs remotely back on SunOS in
1985.
In a closed lab environment with lots of computers, it's quite nice;
the main difference between it and 'rsh' is that it tried harder to
reproduce the local environment, bringing across all the environment
variables. 
rpc.rexd was, of course, promiscuously and infamously insecure.  
(Sun has, I hope, improved its security since then...)

18 years later, I'm in a situation where that functionality
would be very handy: cross-development.  I can happily build
a glibc for embedded processors on my workstation, but glibc's
regression test isn't written to allow remote execution.

Kaz Kojima recently posted source code that wraps execve; 
the wrapper examines the binary being executed, and if it can't 
be run on the local CPU because it's for a different architecture, 
runs it remotely using a homebrew on/rpc.rexd sort of thing.
This would make running the glibc regression test for an alien architecture
easy.

That got me thinking -- why not add that execve wrapper to Linux's
native NFS package?  Then I went looking, and discovered that 
(perhaps wisely) Linux's NFS package doesn't include 'on' or 'rpc.rexd'.

Larry McVoy has something that looks a lot like 'on' to the user, but
(again perhaps wisely) it isn't based on RPC internally.  (see
'bitcluster'.)

So, if only for nostalgia's sake, does anyone know of a re-implementation
of Sun's rpc.rexd service for Linux?

Thanks,
Dan


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
