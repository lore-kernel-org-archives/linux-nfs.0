From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfsd and kswapd
Date: Mon, 07 Jun 2004 10:21:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086596506.24334.9.camel@ikarus.inf.ethz.ch>
References: <002201c44c18$23f45e00$0200000a@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXFO9-0002De-Tr
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 01:21:49 -0700
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXFO9-0002VV-Dk
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 01:21:49 -0700
To: Amir Hermelin <amir@montilio.com>
In-Reply-To: <002201c44c18$23f45e00$0200000a@CARTMAN>
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

Hi Amir,

On Mon, 2004-06-07 at 00:46, Amir Hermelin wrote:
> Hi,
> I'm observing a strange phenomenon running nfsd on 2.4.20 (RH).  I'm using a
> dual-Xeon server with 6GB of memory, and 40 nfsd threads running.  Under
> very heavy load, after a while kswapd starts constantly occupying between
> 60-90% cpu, and every once in a while keventd also wakes up with some 10-
> 30% of its own.  This obviously slows the system and greatly reduces the nfs
> performance.  The strangest thing is, that when I reduce the memory to 512MB
> (with the mem boot option), kswapd seems to be getting a lot less CPU.
> 
> Any explanations on the matter would be greatly appreciated.

Is that a RH 7.3 system? If so, make sure you're running kernel
2.4.20-28 or later, it has the memory management of RH 9 backported and
behaves much better in a setup like yours.

There were many discussions about this on the Dell Linux PowerEdge list,
one thread started here:
http://lists.us.dell.com/pipermail/linux-poweredge/2003-May/024785.html

One workaround is to disable swap, not sure if that's on option for you
though. Depends on what you're running other than file serving.

Greetings,
     Marc



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
