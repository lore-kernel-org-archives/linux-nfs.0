From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: Re: getcwd() returns wrong pathname
Date: Tue, 03 Dec 2002 13:47:04 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021203134704L.miyoshi@hpc.bs1.fc.nec.co.jp>
References: <20021203114545W.miyoshi@hpc.bs1.fc.nec.co.jp>
	<15852.9815.372469.298167@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo202.gate.nec.co.jp ([202.32.8.202])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18J4vN-0007gS-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 20:44:45 -0800
To: neilb@cse.unsw.edu.au
Cc: tanaka-h@mxm.nes.nec.co.jp, hoshi@bsd.tnes.nec.co.jp,
   yamasita@hpc.necst.nec.co.jp, fuku@hpc.bs1.fc.nec.co.jp,
   lgml@linuxdb.hpc.bs1.fc.nec.co.jp
In-Reply-To: <15852.9815.372469.298167@notabene.cse.unsw.edu.au>
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


Hi,

> > I'm having problems with linux NFS. Here is my situation.
> > 
> > When mounting remote linux NFS filesystem to /mnt/xxx/yyy,
> > pwd or getcwd() sometimes returns imcomplete pathname.
> > We are using linux kernel 2.4.17.
> > 
> > % mount linuxserver:/mnt/xxx /mnt/xxx
> > % cd /mnt/xxx/yyy
> > % pwd
> > /xxx/yyy       <--- should be /mnt/xxx/yyy
> > 
> > Is there any ideas or fixes?
> > I'll be very gratefull to any suggestion.
> 
> Are both client and server Linux?

Thank you for your response and sorry for not providing enough
information.

Server is Linux, but client is not linux (NEC enhanced UNIX and HP-UX)
Also I found bugzilla entry which says about same problem on IRIX.

http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=46705

It may be a problem or an incompatibility of those unices,
but if it is a typical incompatibility, I want to know the root
cause of it.

I will be able to collect information from client and/or server,
but what information? Tcpdump output? Kernel trace?

Any suggestions/help for investigatation are welcome.

> What does '/bin/pwd' say?
> What does
>     ls -l /proc/self/cwd
> say?

I will check those information on those unices.

--
MIYOSHI Kazuto <miyoshi@hpc.bs1.fc.nec.co.jp>
 HPC Operating System Group, 1st Computers Software Division,
 Computers Software Operations Unit, NEC Solutions.


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
