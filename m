From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server not responding
Date: 02 Dec 2003 10:37:06 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0ab5izh.fsf@guts.uio.no>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
	<shsptfch1om.fsf@charged.uio.no>
	<1070375865.20333.74.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARCaY-0002aD-JZ
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 07:37:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARCaY-0001I3-3H
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 07:37:22 -0800
To: Douglas Furlong <douglas.furlong@firebox.com>
In-Reply-To: <1070375865.20333.74.camel@wibbit.firebox.com>
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

>>>>> " " == Douglas Furlong <douglas.furlong@firebox.com> writes:

     > If this was the case then i would agree that there is no
     > problem at all, but I am noticing delays of three or four
     > seconds when opening up a new mail in Evolution, or downloading
     > new mail off of the IMAP server (which get stored in the users
     > home directory on the NFS server). When typing in to a mail I
     > will find the text freezes for several seconds, which is fine
     > for me (touch type with accuracy) but other people that are
     > less secure working on PC (read most people I deal with), they
     > find this sort of behaviour unacceptable (which i agree with).

Nobody on this list is directly responsible for the Fedore Core 1
kernel, so whining about what is or isn't acceptable in it won't help.

I have no problems on *any* of the machines in the test-rigs I have at
my disposition when using a standard 2.4.23 kernel.  For the record,
those few that I have used with the Fedora kernel have been fine too
(though I haven't made any detailed tests of that)

     > I have found that all of these error's coincide with the NFS
     > server not responding error messages. Before making the changes

That's no surprise, but a <1-2% retransmission frequency
_DOES_NOT_SUFFICE_ to explain an NFS server not responding messageq. If
those retransmissions are randomly distributed (as they should
normally be) then we're talking unnoticable delays.

If, OTOH, the retransmissions are all occurring at once, then that
might explain it ('cos retransmissions follow an exponential rule
w.r.t. timeouts). Such behaviour would indicate a serious bug, but
you still need to identify where: it could be a NIC driver bug, could
be a problem with the scheduler, it could be a hang somewhere,
somebody may be disabling interrupts for long periods of time...
...or it could be an external problem.

So now, what have you tried in order to diagnose this problem?  Have
you looked at changing NICs, switches etc? Have you tried alternative
kernel builds w/o all the Fedora NPTL+scheduling stuff (e.g. stock
2.4.23)?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
