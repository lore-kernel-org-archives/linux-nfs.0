From: Chip Salzenberg <chip@debian.org>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Fri, 22 Aug 2003 11:10:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030822151042.GD20516@perlsupport.com>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL> <20030820180652.GD3639@perlsupport.com> <16197.46988.88705.455043@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Jordi Mallach <jordi@debian.org>,
	165744-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qDZH-0006MG-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Aug 2003 08:11:11 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16197.46988.88705.455043@gargle.gargle.HOWL>
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

Thanks for the analysis, Neil.  I followed it up until this point:

>    statd tries to notify lockd about the restart
>    statd fails to even send a message, and so forgets about that host

Do you know that?  It seems all we can know for sure about this part
of the history is that the message wasn't received, but for all we
know it may have been sent.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
