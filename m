From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Vaguely NFS related problem
Date: Thu, 12 Dec 2002 14:00:48 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15863.64480.756681.957850@notabene.cse.unsw.edu.au>
References: <3DF7EA94.20108@atheros.com>
	<15863.61586.150820.505519@notabene.cse.unsw.edu.au>
	<3DF7F663.30201@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MJan-0004rF-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 19:00:53 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.234] == wireless-234.wireless.cse.unsw.EDU.AU)
	(for <jeff@atheros.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 12 Dec 2002 14:00:49 +1100
To: "Jeff L. Smith" <jeff@atheros.com>
In-Reply-To: message from Jeff L. Smith on Wednesday December 11
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

On Wednesday December 11, jeff@atheros.com wrote:
> I'm running a kernel I built from kernel.org source.  I found the 
> message in linux-2.4.18/net/sunrpc/svcsock.c.
> 
> 
> printk (KERN_WARNING "RPC: Unable to allocate resbuf from cache!\n");

I think you should check again.  I did and I still cannot find that
message:

% bzcat linux-2.4.18.tar.bz2 | grep 'Unable to allocate resbuf from cache'
%

Are you sure they were *unpatched* kernel.org sources?

I suggest you unroll 2.4.20 and try that.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
