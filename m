From: Gavin Hamill <gdh@acentral.co.uk>
Subject: Re: lockd / statd fun (sorry)
Date: Fri, 23 Apr 2004 12:48:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404231248.30956.gdh@acentral.co.uk>
References: <200404231137.29216.gdh@acentral.co.uk> <200404231332.07891.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGzAX-0002Pw-PB
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:48:33 -0700
Received: from pop.nation-net.com
	([194.200.209.13] helo=pop.walshsimmons.co.uk ident=foobar)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BGzAX-0004ax-5x
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:48:33 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200404231332.07891.bernd-schubert@web.de>
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

On Friday 23 April 2004 12:32, Bernd Schubert wrote:

> Everytime this happens, I fetch the debian nfs-utils source and recompile 
> them without the  '--secure-statd' option.

OK, I did see your message in the archives, but wasn't sure that it was 
relevant here (I'm getting error -13 when you got -5) but I'm game for a 
laugh :)

The workstations are running unstable, whilst the server is on woody. Should I 
only need to update the nfs-common package on the workstations? I don't want 
to touch the server too much if I can help it :)

> Also, the rpc.statd manpage says, that the statd can be protected by 
> the 'tcp_wrapper library'.

<nod> That's what I've done in /etc/hosts.allow - it's a moot point, really 
because it's a firewalled LAN :)

Cheers,
Gavin.


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
