From: Ion Badulescu <ionut@badula.org>
Subject: Re: Perennial question, unable to mount
Date: Tue, 18 Feb 2003 17:39:24 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302182239.h1IMdOG13422@gonzales.badula.org>
References: <001001c2d781$aa6fc580$88693fd1@WEASEL>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lGOv-0000Y2-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 14:39:45 -0800
To: "Steve Wolfe" <nw@codon.com>
In-Reply-To: <001001c2d781$aa6fc580$88693fd1@WEASEL>
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

On Tue, 18 Feb 2003 12:12:19 -0700, Steve Wolfe <nw@codon.com> wrote:

>  On the NFS server, rpcinfo -p shows that mountd is, in fact, listening
> on port 854/udp.  All of the clients are on the same private network,
> using the same physical layer to get to the file server.  I can't think of
> any reason why the client would not be able to reach the file server on
> that port - any suggestions?

Look for a packet filter either on the client, or on the server for this
particular client/port combination.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
