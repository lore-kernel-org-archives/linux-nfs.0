From: Neil Brown <neilb@suse.de>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 10:02:03 +1100
Message-ID: <17917.50411.770610.290399@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT4OC-0000rm-Vj
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:02:13 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HT4OD-0007w8-D2
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:02:15 -0700
In-Reply-To: message from Talpey, Thomas on Friday March 16
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

On Friday March 16, Thomas.Talpey@netapp.com wrote:
> At 04:00 AM 3/16/2007, Neil Brown wrote:
> >I'm keen on getting to nfs-utils-1.1.0 relatively soon and so have
> >been pushing towards it.
> 
> Can you define "relatively"? Weeks? 

I was deliberately being vague :-)
Soon 'relative' to the typical inter-release time for nfs-utils ??

I'd like to have an -rc1 this week or next week.
I'd like lots of people to test it.
I'd like to develop a test-suite for nfs-utils.
I'd like to make final release about 2 weeks after the -rc.

> 
> I guess I'd be concerned about a good long testing cycle before the
> first bump of the second version in, like, forever. Just a perception
> thing from the user community.

Fair enough .... but who runs a .0 anyway?  Doesn't everyone wait for
.1??
But yes, some testing time is important.

> 
> >One thing I have been putting thought into is improvements for statd.
> >Current SLES releases have statd in the kernel and I don't want to
> >continue that, but instead want to make sure that user-space statd
> >provides at least equally good service...
> 
> Does this mean SLES can stop using its own statd if these changes are
> done? If so, that's a good goal.

I hope so.  I don't expect OpenSuSE-10.3 to have an in-kernel statd (that is
not an official statement from SuSE or Novell...)

> 
> >I have also arranged that the new "mount.nfs" will try to start statd
> >if that seems to be appropriate (via a script so statd options can be
> >specified). 
> 
> What conditions make it appropriate? Does it do some kind of nlm ping
> for instance?

Currently it just tests /var/run/rpc.statd.pid.

> 
> Hurray! This is a great approach, especially since the notifies can
> take a long, long time and interfere with other statd functions
> while they're in progress. We did some research on this process
> here as part of other work, btw. I'll look for the list of issues we
> found, there were a couple of interesting ones.

Certainly if there are 'issues' with current statd I'd be very happy
to hear about them.

> 
> >B/ Add functionality to the kernel to register and listen to statd
> >   'notify' requests and act upon them immediately.  This would have
> >   to default to off and only be enabled if a new nfs-utils requested
> >   it.
> 
> I assume you mean the client kernel, or both? In either case...

Both.

> 
> But but but, doesn't this move statd back into the kernel like you
> weren't trying to do? Also, how does it deal with the resolving the
> mon_name in the sm_notify? Won't it depend on a callout (ouch)?

The part of statd that I particularly want to keep out of the kernel
is the creating of files in /var/lib/nfs/sm/.  Listening to RPC
requests and updating internal state accordingly is not very much
different from what lockd does and would seem to fit quite neatly in
the kernel with lockd.

SuSE's kstatd seems to cope without resolving mon_name.
One option is to just ignore it and use the source IP address.  That
would work fine with the default config which uses IP address for all
host identification.
However this doesn't work well for multi-homes hosts and there is a
relatively new sysctl to day "use hostnames".  In that case, maybe we
require the sysadmin to arrange things so a strcmp is all that is
needed.

However if it turns out that name-resolution is really needed in this
path, then I'll definitely keep that part of statd out of the kernel.

Thanks for your thoughts.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
