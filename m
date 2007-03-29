From: Neil Brown <neilb@suse.de>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 19:31:25 +1000
Message-ID: <17931.34669.47062.146703@notabene.brown>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWqyg-00082h-He
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 02:31:30 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWqyi-0007ZJ-Ck
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 02:31:32 -0700
In-Reply-To: message from Jan Rekorajski on Thursday March 29
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday March 29, baggins@sith.mimuw.edu.pl wrote:
> On Thu, 29 Mar 2007, Neil Brown wrote:
> 
> >  Run "statd" only when starting the NFS server.
> >  "statd" should be run before starting the NFS server.
> 
> While you're at it, can you tell me what should be the order of starting
> all NFS/NFS4 daemons? So far I got to this:
> 
> 1) statd
> 2) mountd
> 3) nfsd
> 4) idmapd
> 5) svcgssd
> 6) gssd
> 7) rquotad
> 8) any NFS mounts
> 
> Is it correct?

Hmm... good question.

I think:

  - idmapd and gssd should be started before any nfs mount
  - idmapd and svcgssd should be started before nfsd
  - mountd should start before nfsd.
  - sm-notify should start *after* nfsd.
  - on reflection, statd can probably start slightly after nfsd,
     and if statd is doing the notify, it should definitely be
     after, so my above comment is wrong.  I'll fix it in the
     next RC.
     Similarly it should start before, or atmost slightly after, any
     NFS mount.
  - rquotad should probably start before nfsd, but it probably isn't
    very important.

Rationale:

 sm-notify:
   On an NFS server, this tells the client to reclaim locks.  They
   will try to do so straight away.  If nfsd hasn't started lockd yet,
   they will fail and give up.   This is the most important
   dependency.
   On an NFS client, it simply tells the server to forget about old
   locks, so when it starts isn't terribly important.
 statd:
   This provides service to nfsd/lockd, but also it responds to
   SM_NOTIFY from peers and then needs to talk to the kernel.
   So kernel needs to talk to statd, and statd need to talk to kernel.
   Both sides will retry on failure, so order isn't too important,
   but there should not be a long gap between startup time.
 mountd:
   provides "is this exported" service to nfsd.  If it isn't running
   when the first nfs request arrives, it might be rejected
   incorrectly.  This is probably the second most important
   dependency.
 rquotad:
   provides service to clients completely independently of nfsd
   so when it starts probably doesn't matter.
 idmapd/svcgssd/gssd:
   simply provide service to the kernel modules.   So they should
   be running before the kernel wants them.

I think that covers everything.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
