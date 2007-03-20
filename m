From: Steve Dickson <SteveD@redhat.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 08:32:37 -0400
Message-ID: <45FFD465.4@RedHat.com>
References: <17914.20117.186786.830574@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTdUU-0002sw-7Q
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 05:31:04 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTdUV-0001Sm-UN
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 05:31:04 -0700
In-Reply-To: <17914.20117.186786.830574@notabene.brown>
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

Neil Brown wrote:
> I have changed the default so that statd now compiled with
> RESTRICTED_STATD, so that it only listens to locked for monitor
> requests.  Everyone else is ignored.  There is no-one else who uses
> statd anywhere, so this should be perfectly safe and is more secure.
It just occurred to me that this may not be a good idea... Unless
there has been some changes in the area, turn this on will
break locking... The reason I know this is that I turned it on
at one point and people started to see the following messages
being logged:
  nsm_mon_unmon: rpc failed, status=-13
  lockd: cannot monitor 192.168.1.202

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=140385
has the details...

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
