From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Must portmap listen on * in NFS clients?
Date: Tue, 16 Dec 2003 08:54:58 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16350.11698.753743.894163@notabene.cse.unsw.edu.au>
References: <20031215214844.GR20533@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AW0gR-0005SF-Ey
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 13:55:19 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AW0gR-00052M-2e
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 13:55:19 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 16 Dec 2003 08:55:01 +1100
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Monday December 15
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

On Monday December 15, chip@pobox.com wrote:
> I have a question that will soon be relevant for Debian NFS packaging.
> 
> As far as NFS is concerned, need portmap listen on all interfaces when
> the machine it's on is only an NFS *client*?  I know that servers'
> portmaps must listen on * so clients can find mountd.  But, AFAICT,
> clients need not have open portmaps.  Am I right in this?
> 

Locking needs bi-directional RPC service.
In particular, the server needs to be able to communicate with statd
on the client to ask it to inform the server if the client restarts,
so the server can drop any locks the client had.


> PS: I should already know this.  But NFS protocol issues have always
>     given me the screaming heebie jeebies.

This is completely understandable :-)  The simplicity of the core NFS
protocol is both a strength (it is easy to implement) and a weakness
(all sorts of horrible stuff had to back hacked on afterwards to make
it actually work).

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
