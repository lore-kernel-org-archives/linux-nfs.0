From: Juan Gomez <juang@us.ibm.com>
Subject: Re: NFS digest, Vol 1 #1101 - 2 msgs
Date: Mon, 26 Aug 2002 09:54:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFBBEF659B.543ADE6B-ON87256C21.005CD303@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jN9N-0000Ni-00
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 09:55:37 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.194.23])
	by e1.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g7QGsonM155848
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 12:54:51 -0400
Received: from d03nm694.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay02.boulder.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g7QGsmN6032144
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 10:54:48 -0600
To: nfs@lists.sourceforge.net
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





I have submitted patches to Neil to do the IP aliasing thing in statd,
hopefully he will soon release those.


Juan Gomez/IBM Research




|---------+--------------------------------->
|         |           nfs-request@lists.    |
|         |           sourceforge.net       |
|         |           Sent by: nfs-         |
|         |           admin@lists.          |
|         |           sourceforge.net       |
|         |                                 |
|         |                                 |
|         |           08/25/02 12:01 PM     |
|         |           Please respond to nfs |
|         |                                 |
|---------+--------------------------------->
  >-----------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                             |
  |       To:       nfs@lists.sourceforge.net                                                                                   |
  |       cc:                                                                                                                   |
  |       Subject:  NFS digest, Vol 1 #1101 - 2 msgs                                                                            |
  |                                                                                                                             |
  |                                                                                                                             |
  >-----------------------------------------------------------------------------------------------------------------------------|



Send NFS mailing list submissions to
             nfs@lists.sourceforge.net

To subscribe or unsubscribe via the World Wide Web, visit
             https://lists.sourceforge.net/lists/listinfo/nfs
or, via email, send a message with subject or body 'help' to
             nfs-request@lists.sourceforge.net

You can reach the person managing the list at
             nfs-admin@lists.sourceforge.net

When replying, please edit your Subject line so it is more specific
than "Re: Contents of NFS digest..."


Today's Topics:

   1. High Availability NFS Proposal (James Bottomley)
   2. Re: High Availability NFS Proposal (Bill Rugolsky Jr.)

--__--__--

Message: 1
To: nfs@lists.sourceforge.net
cc: James.Bottomley@SteelEye.com, lmb@suse.de
Date: Sat, 24 Aug 2002 18:16:03 -0400
From: James Bottomley <James.Bottomley@steeleye.com>
Subject: [NFS] High Availability NFS Proposal

Hi All,

My company, SteelEye Technology, already has a HA-NFS offering (using
filehandle aliasing and kernel authentication add ons).  However, We'd like
to
enhance the existing open source solution (actually, our current patches
are
open source, I just got tired of merging them to each revision of whatever
distributions kernel).  The new fsid option already performs the same task
as
our kernel filehandle aliasing patches, so the only remaining issues are
authentication and locking.

Unfortunately, our product, LifeKeeper, is more complex than just a simple
two
node active passive cluster, so the usual just share /var/lib/nfs solution
won't work for us.  What I'd like to propose instead is to place hooks
inside
mountd and statd that would allow them to propagate the necessary state
information into a cluster.  The best way I can think of is to designate
two
executable hooks (say /var/lib/nfs/mountd-hook and /var/lib/nfs/statd-
hook).
If mountd and statd don't find these on start up, they proceed normally.
However, if they exist, mountd and statd will execute them with certain
arguments to allow the clustering software to keep track of the client
machines correctly.

These modifications should be enough to allow HA-NFS.  However, to preserve

locks on failover, I need to introduce statd to the concept of virtual
hosts,
so it can be told to stop tracking a virtual host, or behave as though a
virtual host had crashed.  There are already the beginnings of IP aliasing
support in statd.c, so it shouldn't be too hard to progress to the full
blown
solution.

I'll proceed in two phases: mountd first to give a HA solution and statd
next
to give the complete HA-NFS solution.  The hooks should be useable by any
HA
clustering software on Linux.

Any feedback anyone might have on this proposal would be more than welcome.

James Bottomley




--__--__--

Message: 2
Date: Sun, 25 Aug 2002 01:28:16 -0400
From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
To: James Bottomley <James.Bottomley@SteelEye.com>
Cc: nfs@lists.sourceforge.net, lmb@suse.de
Subject: Re: [NFS] High Availability NFS Proposal

On Sat, Aug 24, 2002 at 06:16:03PM -0400, James Bottomley wrote:
> Unfortunately, our product, LifeKeeper, is more complex than just a
simple two
> node active passive cluster, so the usual just share /var/lib/nfs
solution
> won't work for us.  What I'd like to propose instead is to place hooks
inside
> mountd and statd that would allow them to propagate the necessary state
> information into a cluster.  The best way I can think of is to designate
two
> executable hooks (say /var/lib/nfs/mountd-hook and /var/lib/nfs/statd-
hook).
> If mountd and statd don't find these on start up, they proceed normally.

> However, if they exist, mountd and statd will execute them with certain
> arguments to allow the clustering software to keep track of the client
> machines correctly.

James,

Neil Brown has said that he is working on the NFS authentication
infrastructure,
which apparently includes some userland notification infrastructure for
mountd.
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

I expect that that details of Neil's work on this has evolved in light of
the
direction that NFSv4 has taken, but remains largely the same in broad
outline.
Best to ask Neil about that, of course. :-)

Regards,

  Bill Rugolsky



--__--__--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


End of NFS Digest





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
