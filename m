From: Neil Brown <neilb@suse.de>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Thu, 22 Mar 2007 15:30:47 +1100
Message-ID: <17922.1655.967323.732476@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown> <45FFD465.4@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUEx2-0005ck-UZ
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 21:31:01 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUEx3-0003bz-GX
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 21:31:03 -0700
In-Reply-To: message from Steve Dickson on Tuesday March 20
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

On Tuesday March 20, SteveD@redhat.com wrote:
> Neil Brown wrote:
> > I have changed the default so that statd now compiled with
> > RESTRICTED_STATD, so that it only listens to locked for monitor
> > requests.  Everyone else is ignored.  There is no-one else who uses
> > statd anywhere, so this should be perfectly safe and is more secure.
> It just occurred to me that this may not be a good idea... Unless
> there has been some changes in the area, turn this on will
> break locking... The reason I know this is that I turned it on
> at one point and people started to see the following messages
> being logged:
>   nsm_mon_unmon: rpc failed, status=-13
>   lockd: cannot monitor 192.168.1.202
> 
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=140385
> has the details...
> 
> steved.

Thanks for the info and the link.

It's a shame you weren't able to reproduce it as it means it isn't
something we can easily test for in a new version.

The "status=-13" suggests an rpc-level failure.  E.g. not being able
to get a useful answer from portmap or getting an error from the rpc
client library like an xdr decoding error.
As you say in the bz, it looks like statd has died, except that
apparently it hasn't.

The
  Received erroneous SM_UNMON request from server for client1
messages do make sense.  RESTRICTED_STATD forces 'my_name' to be
127.0.0.1 for MON requests but not for UNMON requests, so unless the
hostname maps to 127.0.0.1, you will get this error.  I can fix that.

But I cannot see how this or anything else that is RESTRICTED_STATD
specific could cause statd to stop servicing requests.

My guess is that a 'netstat -n' would have shown a large queue of
requests to statd that were not being served - statd still there but
not responding for some reason, possibly in an infinite loop, though I
cannot find it.


Hmm... I just noticed that statd sets REUSEADDR on the udp port that
it listens on.  So if another process binds to the same port it will
succeed and will get some (maybe all) of the packets meant for statd.
That might cause lots of 'cannot monitor' messages.... but I cannot
see how it could be connected to RESTRICTED_STATD.

I'm still inclined to make RESTRICTED_STATD the default, to fix what
bugs I can find, and to test it as thoroughly as I can...

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
