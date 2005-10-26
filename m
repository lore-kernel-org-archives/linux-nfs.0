From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data coherency trouble with
	multiple	clients,	on2.6.14-rc5
Date: Wed, 26 Oct 2005 17:05:41 -0400
Message-ID: <1130360742.8859.56.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>
	 <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com>
	 <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUsTJ-0000b4-Ow
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 14:06:09 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUsTH-00024j-46
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 14:06:09 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <435FDEA9.5060706@redhat.com>
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

on den 26.10.2005 klokka 15:53 (-0400) skreiv Peter Staubach:
> This brings lots of extra guarantees, actually.  Just because the file is
> open for writing does not mean that there are any dirty pages hanging
> around waiting to be written.  And, even if there are, they will get
> flushed when the conflict is detected.  Last there one there wins.  This
> is even the policy when local processes conflict on the same file in the
> same region.
> 
> This policy would address the situation that was reported here.
> 
> This policy will definitely result in _much_ stronger caching semantics
> than does close-to-open.  These two policies together can usually result
> in reasonable cache consistency, enough for most applications.  Applications
> which need stronger cache consistency should be advisory locking in order
> to synchronize access to the file.

Sure, but the big issue here is how to actually detect conflicts (and
avoid excessive false positives).

NFSv3 does in theory give you the option of detecting conflicts using
weak cache consistency. In practice, write reordering and the fact that
most servers violate the requirement given by RFC1813 that pre/post-op
attributes should be atomic w.r.t. the main operation prevents you from
closing the hole.
NFSv2 and NFSv4 don't even have support for WCC, so your detection
scheme ends up being very dependent on one particular version of NFS.

Basically, what I'm saying is that as long as we cannot implement the
above ideal, we should not be issuing promises to application developers
that they can rely on it. O_DIRECT was specifically developed in order
to give database implementers a reliable uncached I/O interface, and so
that is what we should direct them towards.
The worst thing to do when someone asks IMHO is to reply that "we can
almost but not quite fix noac".

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
