From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file xfer of size of client memory = bad scene
Date: Sat, 15 Jan 2005 00:43:06 -0500
Message-ID: <1105767787.10922.9.camel@lade.trondhjem.org>
References: <41E856FE.6080706@mitre.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpgiY-0007su-Fb
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 21:43:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CpgiW-0006de-TL
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 21:43:22 -0800
To: Jeff Blaine <jblaine@mitre.org>
In-Reply-To: <41E856FE.6080706@mitre.org>
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

fr den 14.01.2005 Klokka 18:34 (-0500) skreiv Jeff Blaine:
> I have a box with 4GB.  It's running 2.6.10.
> 
> I am trying to run Iozone with -g and an argument to it
> that is larger than the physical memory in the NFSv3
> client machine.
> 
> For instance, on this 4GB box, I am trying '-g 4224m'.
> More specifically, the entire command line is:
> 
>      ./iozone -a -g 4224m -f /sol9box/testfile
> 
> As soon as it finally gets to trying a file size of
> 4194304, oom-killer steps in and starts blasting
> processes off my machine (WTF?  Great.)
> 

I suggest you take this bug up to LKML or the memory management lists.
It is the responsibility of the VM to initiate flushing of data when the
memory pressure gets too high: the NFS subsystems have little control
over this matter.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
