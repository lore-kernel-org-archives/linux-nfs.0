From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: High Availability NFS Proposal
Date: Sun, 25 Aug 2002 01:28:16 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020825012816.A7902@ti19>
References: <200208242216.g7OMG3802286@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 209-166-240-202.cust.walrus.com.240.166.209.in-addr.arpa ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ipx9-00069O-00
	for <nfs@lists.sourceforge.net>; Sat, 24 Aug 2002 22:28:47 -0700
To: James Bottomley <James.Bottomley@SteelEye.com>
In-Reply-To: <200208242216.g7OMG3802286@localhost.localdomain>; from James.Bottomley@SteelEye.com on Sat, Aug 24, 2002 at 06:16:03PM -0400
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Sat, Aug 24, 2002 at 06:16:03PM -0400, James Bottomley wrote:
> Unfortunately, our product, LifeKeeper, is more complex than just a simple two 
> node active passive cluster, so the usual just share /var/lib/nfs solution 
> won't work for us.  What I'd like to propose instead is to place hooks inside 
> mountd and statd that would allow them to propagate the necessary state 
> information into a cluster.  The best way I can think of is to designate two 
> executable hooks (say /var/lib/nfs/mountd-hook and /var/lib/nfs/statd-hook).  
> If mountd and statd don't find these on start up, they proceed normally.  
> However, if they exist, mountd and statd will execute them with certain 
> arguments to allow the clustering software to keep track of the client 
> machines correctly.

James,

Neil Brown has said that he is working on the NFS authentication infrastructure,
which apparently includes some userland notification infrastructure for mountd.
You will probably want to take note of his work when deciding on the format
of those "certain arguments" to the notification hooks.

Back in 2.2.x, David Woodhouse wrote code (never merged) that added
mountd upcalls to knfsd.  The code was modified by Elvis Pftzenreuter
<epx@conectiva.com.br>, then updated by Luis Claudio R. Goncalves
<lclaudio@conectiva.com.br>.  IIRC, the original impetus was to handle
re-authentication in the presence of wildcard (netgroup, etc.) exports
in a sane way.

You can find Elvis's original patchset here:

http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837303295&w=2

Some of Neil Brown's early comments on how to improve and generalize the
infrastructure can be found here:

http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837303307&w=2

I expect that that details of Neil's work on this has evolved in light of the
direction that NFSv4 has taken, but remains largely the same in broad outline.
Best to ask Neil about that, of course. :-)

Regards,

  Bill Rugolsky


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
