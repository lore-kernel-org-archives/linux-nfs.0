From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Fri, 16 Mar 2007 08:59:49 -0400
Message-ID: <EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
References: <17914.20117.186786.830574@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSC2k-0006jq-6h
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 06:00:26 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSC2l-0001tw-2M
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 06:00:28 -0700
In-Reply-To: <17914.20117.186786.830574@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
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

At 04:00 AM 3/16/2007, Neil Brown wrote:
>I'm keen on getting to nfs-utils-1.1.0 relatively soon and so have
>been pushing towards it.

Can you define "relatively"? Weeks? 

I guess I'd be concerned about a good long testing cycle before the
first bump of the second version in, like, forever. Just a perception
thing from the user community.

>One thing I have been putting thought into is improvements for statd.
>Current SLES releases have statd in the kernel and I don't want to
>continue that, but instead want to make sure that user-space statd
>provides at least equally good service...

Does this mean SLES can stop using its own statd if these changes are
done? If so, that's a good goal.

>I have also arranged that the new "mount.nfs" will try to start statd
>if that seems to be appropriate (via a script so statd options can be
>specified). 

What conditions make it appropriate? Does it do some kind of nlm ping
for instance?

 Said script is not currently in .git,
>A/ create a separate program "statd-notify" that just performs
>  operation 3.  It is always run at boot time, but often exits
>  very soon.  When statd starts it possibly forks and runs 
>  "statd-notify" depending on options.  
>  Then all that code can be removed from statd.

Hurray! This is a great approach, especially since the notifies can
take a long, long time and interfere with other statd functions
while they're in progress. We did some research on this process
here as part of other work, btw. I'll look for the list of issues we
found, there were a couple of interesting ones.

>B/ Add functionality to the kernel to register and listen to statd
>   'notify' requests and act upon them immediately.  This would have
>   to default to off and only be enabled if a new nfs-utils requested
>   it.

I assume you mean the client kernel, or both? In either case...

But but but, doesn't this move statd back into the kernel like you
weren't trying to do? Also, how does it deal with the resolving the
mon_name in the sm_notify? Won't it depend on a callout (ouch)?

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
