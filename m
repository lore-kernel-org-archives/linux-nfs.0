From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: High Availability NFS Proposal
Date: 25 Aug 2002 21:36:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1030336593.11097.11.camel@camp4.serpentine.com>
References: <200208242216.g7OMG3802286@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl092-013-071.sfo1.dsl.speakeasy.net ([66.92.13.71] helo=pelerin.serpentine.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jBcC-0000M1-00
	for <nfs@lists.sourceforge.net>; Sun, 25 Aug 2002 21:36:36 -0700
To: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: <200208242216.g7OMG3802286@localhost.localdomain>
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

On Sat, 2002-08-24 at 15:16, James Bottomley wrote:

> Unfortunately, our product, LifeKeeper, is more complex than just a simple two 
> node active passive cluster, so the usual just share /var/lib/nfs solution 
> won't work for us.  What I'd like to propose instead is to place hooks inside 
> mountd and statd that would allow them to propagate the necessary state 
> information into a cluster.  The best way I can think of is to designate two 
> executable hooks (say /var/lib/nfs/mountd-hook and /var/lib/nfs/statd-hook).  

What would you plan on sharing via these hooks that isn't already
maintained in /var/lib/nfs?  Why not use dnotify to capture changes to
those files, and push them out as clients come and go?

	<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
