From: jmoyer@redhat.com
Subject: Re: [autofs] [RFC] Multiple server selection and replicated mount failover
Date: Tue, 02 May 2006 15:12:38 -0400
Message-ID: <x49lktkkzq1.fsf@redhat.com>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	<Pine.LNX.4.63.0605021028330.17078@simba.math.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fb0Eo-0001wT-S7
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:08:46 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fb0Eo-0004ki-M7
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:08:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fb0En-0000RY-83
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 12:08:46 -0700
To: Jim Carter <jimc@math.ucla.edu>
In-Reply-To: <Pine.LNX.4.63.0605021028330.17078@simba.math.ucla.edu> (Jim Carter's message of "Tue, 2 May 2006 11:14:09 -0700 (PDT)")
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

==> Regarding Re: [autofs] [RFC] Multiple server selection and replicated mount failover; Jim Carter <jimc@math.ucla.edu> adds:

jimc> On Tue, 2 May 2006, Ian Kent wrote:
>> For some time now I have had code in autofs that attempts to select an
>> appropriate server from a weighted list to satisfy server priority
>> selection and Replicated Server requirements. The code has been
>> problematic from the beginning and is still incorrect largely due to me
>> not merging the original patch well and also not fixing it correctly
>> afterward.
>> 
>> So I'd like to have this work properly and to do that I also need to
>> consider read-only NFS mount fail over.

jimc> I'm glad to hear that there may be progress in server selection. But
jimc> I'm not sure if you're looking at the problem from the direction that
jimc> I am.

jimc> First, I don't think it's necessary to replicate the original Sun
jimc> behavior exactly, although it would be helpful but not mandatory to
jimc> allow something in the automount maps that resembles Solaris syntax,
jimc> to ease user (sysop) training.

Jim,

In my dealings with the automounter over the past 2.5 years, the major pain
point is that the Linux automounter does not function the same as that of
other UNIXes.  Interoperability is a HUGE problem.  I agree that the
replicated server selection business is, in some cases, a bit difficult to
follow.  However, we can't simply ignore an enormous install base.

jimc> The current version of mount on Linux (util-linux-2.12) does not know
jimc> about picking servers from a list; at least the man page doesn't
jimc> know.  This means that the whole job of server selection falls to
jimc> automount.  I think that's the right way to design the system.
jimc> However, that also means that automount needs to know something about
jimc> NFS servers specifically.  The less it knows, the better, in my
jimc> opinion, so the design of NFS mount options can be separated from
jimc> automount.

When initially thinking about this problem, I came to the same conclusion:
most, if not all of the server selection should be done in the automount
daemon.  However, when you take into account the read-only NFS failover,
you realize that the kernel may have to figure a lot of this stuff out
anyway.

I'd really like to hear from someone with NFS expertise how they envision
read-only NFS failover working.  We can take the server selection out of
the loop for the moment, and just concentrate on mechanics.  Once we have a
good picture of how that will look, we can decide how to implement the
actual policy.

jimc> You asked where various steps should be implemented.  Picking the
jimc> server: that's the job of the userspace daemon, and I don't see too
jimc> much help that the kernel might give.  Readonly failover is another
jimc> matter -- which I think is important.

jimc> Here's a top of head kludge for failover: Autofs furnishes a
jimc> synthetic directory, let's call it /net/warez.  The user daemon NFS
jimc> mounts something on it, example julia:/m1/warez.  The user daemon
jimc> mounts another inter-layer, maybe FUSE, on top of the NFS, and client
jimc> I/O operations go to that filesystem.  When the inter-layer starts
jimc> getting I/O errors because the NFS driver has decided that the server
jimc> is dead, the inter-layer notifies the automount daemon. It tells the
jimc> kernel autofs driver to create a temp name /net/xyz123, and it mounts
jimc> a different server on it, let's say sonia:/m2/warez.  Then the names
jimc> are renamed to, respectively, /net/xyz124 and /net/warez (the new
jimc> one).  Finally the automount daemon does a "bind" or "move" mount to
jimc> transfer the inter-layer to be mounted on the new /net/warez.  Then
jimc> the I/O operation has to be re-tried on the new server.  Wrecked
jimc> directories are cleaned up as circumstances allow.

We can do better than this.  Again, I'd like to hear some ideas from Trond
et. al. on how this could be accomplished in a clean way.

-Jeff



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
