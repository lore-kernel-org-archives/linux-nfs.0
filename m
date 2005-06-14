From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: Flushing of cached data on NFS server
Date: Tue, 14 Jun 2005 08:02:13 -0500
Message-ID: <EXCHG2003w0m25q8awY00000521@EXCHG2003.microtech-ks.com>
References: <9E621559095AA746B22B21CD4FAF99A521A642@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiB2D-00072F-A5
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 06:00:53 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DiB2B-0002WE-Sq
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 06:00:52 -0700
To: "'Edward Hibbert'" <Edward.Hibbert@dataconnection.com>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A521A642@EDINMAIL1.ad.datcon.co.uk>
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


A dirty trick that I have used on local filesystems that was running
into response time issues when flushes happened was to run sync
and sleep for n seconds and then run it again in a loop, this
used to be the default on all unixes but at some point either
was taken over by the kernel, or no longer worried about, on 
the local machine we were able to confirm that almost all of
memory was filled with dirty write caches, of course this won't
happen on a nfs server with sync set on the export, it may well
be that it will happens on certain filer as they are not exporting
sync.

The problem with the local machine we were having was that when
all 64GB of ram filled up, the IO speed went down by quite a bit,
adding in the sync every 30 seconds make this slow down go away.

                                Roger 

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Edward Hibbert
> Sent: Tuesday, June 14, 2005 5:35 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Flushing of cached data on NFS server
> 
> We're running against a Linux-based NFS server (actually a 
> SNAP filer).  What we see is that when its cache gets full, 
> it flushes out the data using bdflush, as you'd expect.  This 
> may take several seconds, and during this time responsiveness 
> dives - NFS operations take several seconds, RPC 
> retransmissions start happening, and so on.
> 
> What I'd like is a way of tuning the server to remain 
> responsive at all times (e.g. by more regular flushing).  
> I've had a play with bdflush parameters, but it's kind of 
> stabbing in the dark and I'm not, erm, drawing blood.
> 
> Does anyone have any experience at tuning NFS servers for 
> consistently low latency?
> 
> Regards,
> 
> Edward.
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: NEC IT Guy Games.  How far 
> can you shotput a projector? How fast can you ride your desk 
> chair down the office luge track?
> If you want to score the big prize, get to know the little guy.  
> Play to win an NEC 61" plasma display: 
> http://www.necitguy.com/?r 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
