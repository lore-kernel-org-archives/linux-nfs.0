From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server not responding
Date: 28 Nov 2003 11:56:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptfch1om.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Douglas Furlong <douglas.furlong@firebox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APlv1-0002oB-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 08:56:35 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1APlv0-0000Ow-UG
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 08:56:35 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
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

>>>>> " " == Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:


     > I also see something like 0.8-1% retransmissions and these
     > messages on newly installed Fedora Core 1 on some cluster
     > nodes, using default r/wsize (8192). As I'm using root-NFS, the
     > node is quite useless when this situation happens. I'm sure

Huh? Why should a 1% retransmission make a noticable difference? Be
realistic: we're talking about a delay of 100ms on 1/100 requests...
I get ~2% retransmission rate when I do UDP loopback mounts without
seeing any problems at all: it still compares well to the same mount
using TCP.

Now it may be that the Fedora kernel has some other crap in it that is
screwing up interrupts & other such things (NAPI perhaps?). Has
anybody that is seeing these problems made a comparison with an
equivalent stock Marcelo kernel?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
