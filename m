From: Chip Salzenberg <chip@debian.org>
Subject: Re: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Thu, 21 Aug 2003 10:48:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821144811.GH14355@perlsupport.com>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL> <20030813082216.GA14015@nubol.int.oskuro.net> <20030820175951.GB3639@perlsupport.com> <20030821075826.GA27391@nubol.int.oskuro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pr3b-0007oE-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 08:09:00 -0700
To: Jordi Mallach <jordi@debian.org>
In-Reply-To: <20030821075826.GA27391@nubol.int.oskuro.net>
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

According to Jordi Mallach:
> I have never used tcpdump more than to play a little, so I could use
> some pointers about what I should look at.

First you use 'rpcinfo -p' to see which ports statd is listening to
on the machine where statd is complaining:

   $ rpcinfo -p | grep status
       100024    1   udp    936  status
       100024    1   tcp    939  status

That's udp port 936 and tcp port 939.  Then you want to watch all
traffic to/from those ports:

   # tcpdump udp port 936 or tcp port 939

You may also need to specify "-i eth1" or whatever if the IP address
you're seeing isn't on your eth0.

Then you sit and watch.  A combination of "screen" and "script" may
also be helpful.  The man page for tcpdump, section "OUTPUT FORMAT",
explains how to interpret the output.

The key thing is the source IP and port of whoever's talking to statd.
Then you go to the source machine and use 'lsof' to see what program
has bound to that port.  If the program is gone by the time you get
there, you'll need to prevent statd from answering the request, which
will entail compiling a custom statd or perhaps using iptables to kill
any outgoing answer packets.
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
