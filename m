From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Mon, 25 Aug 2003 16:37:57 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16201.44741.447738.365920@gargle.gargle.HOWL>
References: <20030812152154.GQ24349@perlsupport.com>
	<16185.47443.33945.603458@gargle.gargle.HOWL>
	<20030820180652.GD3639@perlsupport.com>
	<16197.46988.88705.455043@gargle.gargle.HOWL>
	<20030822151042.GD20516@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Jordi Mallach <jordi@debian.org>,
    165744-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rAzO-0001TA-00
	for <nfs@lists.sourceforge.net>; Sun, 24 Aug 2003 23:38:06 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@debian.org>) (for <nfs@lists.sourceforge.net>)
	(for <jordi@debian.org>) (for <165744-quiet@bugs.debian.org>) By note
	With Smtp ; Mon, 25 Aug 2003 16:37:57 +1000
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: message from Chip Salzenberg on Friday August 22
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

On Friday August 22, chip@debian.org wrote:
> Thanks for the analysis, Neil.  I followed it up until this point:
> 
> >    statd tries to notify lockd about the restart
> >    statd fails to even send a message, and so forgets about that host
> 
> Do you know that?  It seems all we can know for sure about this part
> of the history is that the message wasn't received, but for all we
> know it may have been sent.

The 

  elrond rpc.statd[179]: notify_host: failed to notify 127.0.0.1

messages indicate that the "sendto" in utils/statd/rmtcall.c(xmit_call)
failed, which suggests that the message wasn't sent.
It might actually be sending a port-lookup call to portmap at this
point.  It is certainly odd that that fails....

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
