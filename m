From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.0-test3-bk10-final regression getting out of hand
Date: 04 Nov 2003 01:35:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssml4ljze.fsf@charged.uio.no>
References: <20031031214851.0d6e604b.lista2@comhem.se>
	<bo0n20$c3q$1@foehn.quickstep.oche.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGumR-0008Ix-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Nov 2003 22:35:07 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AGumQ-0002ut-Pj
	for nfs@lists.sourceforge.net; Mon, 03 Nov 2003 22:35:06 -0800
To: Martin Spott <Martin.Spott@uni-duisburg.de>
In-Reply-To: <bo0n20$c3q$1@foehn.quickstep.oche.de>
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

>>>>> " " == Martin Spott <Martin.Spott@uni-duisburg.de> writes:

     > completely freezes _any_ NFS traffic with the same server.  Are
     > there any significant changes to the NFS client I should back
     > out for the purpose of finding the 'bug' ?

Err... If you believe it is the client, they I suggest backing out
_all_ client related patches between test7 and test8 for a start...

Personally, I'm starting to suspect some of the IPv4 changes. I'm
seeing wierd crap with the TCP code which suggests some form of memory
corruption. The corruption is occurring on both the client *and*
server side.
The fact that I'm seeing signs of memory poisoning suggests it is
probably an skb being freed too early or something like that.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
