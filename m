From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Fri, 22 Aug 2003 16:26:20 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16197.46988.88705.455043@gargle.gargle.HOWL>
References: <20030812152154.GQ24349@perlsupport.com>
	<16185.47443.33945.603458@gargle.gargle.HOWL>
	<20030820180652.GD3639@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Jordi Mallach <jordi@debian.org>,
    165744-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19q5Nb-0007Xm-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 23:26:36 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@debian.org>) (for <nfs@lists.sourceforge.net>)
	(for <jordi@debian.org>) (for <165744-quiet@bugs.debian.org>) By note
	With Smtp ; Fri, 22 Aug 2003 16:26:29 +1000
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: message from Chip Salzenberg on Wednesday August 20
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

On Wednesday August 20, chip@debian.org wrote:
> According to Neil Brown:
> > The first is the "Call to statd from non-local host".  Given that
> > the in-kernel lockd *always* uses 127.0.0.1 to talk to statd, this
> > request cannot have come from there.
> 
> Neil, would you be so kind as to examine this old (nearly a year now),
> but still open, Debian bug report?
> 
>     http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=165744
> 
> This complaint *is* very rare, but it seems not to be specific to the
> use of 2.6.  Or do you think you know what's up with this old report?
> Please advise.

Sorry, but I'm at a bit of a loss.

It seems that 
   lockd asked statd to monitor some host.
   statd gets information that the host has restarted.
   statd tries to notify lockd about the restart
   statd fails to even send a message, and so forgets about that host
   lockd asked statd to unmonitor the host, and statd doesn't know
       what it is talking about

If you (or someone) could play around and find a sequence of events
that would reproduce the problem it would, of course, help a lot.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
