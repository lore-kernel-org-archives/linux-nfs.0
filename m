From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Exportfs does not accept Knoppix /ramdisk/home
Date: Tue, 14 Jun 2005 15:29:33 +1000
Message-ID: <17070.27453.148353.381340@cse.unsw.edu.au>
References: <42AE148E.80904@mindspring.com>
	<17070.5793.185404.226427@cse.unsw.edu.au>
	<42AE6611.4000709@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Di3zc-0003At-GE
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 22:29:44 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Di3za-0004eK-Pl
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 22:29:44 -0700
To: Larry Alkoff <labradley@mindspring.com>
In-Reply-To: message from Larry Alkoff on Tuesday June 14
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

On Tuesday June 14, labradley@mindspring.com wrote:
> 
> 
> The good news - I tried your line exactly as above and
> exportfs -rav
> worked as expected.

Excellent.

> 
> Bad news - for some reason I'm getting the error message:
> Mounting knoppix
> mount: RPC: Remote system error - No route to host
> 

maybe portmap is being run with "-i 127.0.0.1", meaning "only listen
on the loopback interface".
If so, try running as just plain "portmap".

> I've seen that before but it was always fixed by making sure
> portmap, nfsd, mountd and statd were running.
> 
> They are running on both machines except that on knoppix it's
> just "portmap" and on my normal Slackware machine it's "RPC.portmap" 
> plus a new one "RPC.quotad".

The name differences are purely cosmetic.

> 
> It's been a while since I fooled with nfs.  Do I need entries in
> fstab?

No.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
