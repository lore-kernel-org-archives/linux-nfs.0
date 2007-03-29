From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 10:30:09 -0400
Message-ID: <EXNANE01WtIIZS2TRqf0000049a@exnane01.hq.netapp.com>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWveo-0004jv-1O
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:31:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWveo-0004Ur-39
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:31:20 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l2TEUZ3O019859
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 07:30:35 -0700 (PDT)
In-Reply-To: <17931.34669.47062.146703@notabene.brown>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
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

At 05:31 AM 3/29/2007, Neil Brown wrote:
>On Thursday March 29, baggins@sith.mimuw.edu.pl wrote:
>> On Thu, 29 Mar 2007, Neil Brown wrote:
>> 
>> >  Run "statd" only when starting the NFS server.
>> >  "statd" should be run before starting the NFS server.
>> 
>> While you're at it, can you tell me what should be the order of starting
>> all NFS/NFS4 daemons? So far I got to this:
>> 

Don't forget...

0) portmapper

*This* is the most important one! ;-) Interesting things happen when
portmapper isn't present btw, some clients fail to retry if they get errors
on portmap lookups. They often fail to retry if the portmapper replies
with a zero port (service not found), which is the more common startup
ordering issue.

Really interesting things happen after the statmon notifications, if clients
start to reclaim and fail to find the portmapper or the lock manager. Solaris,
for example, starts killing client processes with SIGLOST. So I agree that
it is critical to ensure that portmap, statd and nfsd (which implies lockd
on Linux of course) are started before the server's notifications.

Tom.


>> 1) statd
>> 2) mountd
>> 3) nfsd
>> 4) idmapd
>> 5) svcgssd
>> 6) gssd
>> 7) rquotad
>> 8) any NFS mounts
>> 
>> Is it correct?
>
>Hmm... good question.
>
>I think:
>
>  - idmapd and gssd should be started before any nfs mount
>  - idmapd and svcgssd should be started before nfsd
>  - mountd should start before nfsd.
>  - sm-notify should start *after* nfsd.
>  - on reflection, statd can probably start slightly after nfsd,
>     and if statd is doing the notify, it should definitely be
>     after, so my above comment is wrong.  I'll fix it in the
>     next RC.
>     Similarly it should start before, or atmost slightly after, any
>     NFS mount.
>  - rquotad should probably start before nfsd, but it probably isn't
>    very important.
>
>Rationale:
>
> sm-notify:
>   On an NFS server, this tells the client to reclaim locks.  They
>   will try to do so straight away.  If nfsd hasn't started lockd yet,
>   they will fail and give up.   This is the most important
>   dependency.
>   On an NFS client, it simply tells the server to forget about old
>   locks, so when it starts isn't terribly important.
> statd:
>   This provides service to nfsd/lockd, but also it responds to
>   SM_NOTIFY from peers and then needs to talk to the kernel.
>   So kernel needs to talk to statd, and statd need to talk to kernel.
>   Both sides will retry on failure, so order isn't too important,
>   but there should not be a long gap between startup time.
> mountd:
>   provides "is this exported" service to nfsd.  If it isn't running
>   when the first nfs request arrives, it might be rejected
>   incorrectly.  This is probably the second most important
>   dependency.
> rquotad:
>   provides service to clients completely independently of nfsd
>   so when it starts probably doesn't matter.
> idmapd/svcgssd/gssd:
>   simply provide service to the kernel modules.   So they should
>   be running before the kernel wants them.
>
>I think that covers everything.
>
>NeilBrown
>
>-------------------------------------------------------------------------
>Take Surveys. Earn Cash. Influence the Future of IT
>Join SourceForge.net's Techsay panel and you'll get the chance to share your
>opinions on IT & business topics through brief surveys-and earn cash
>http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
