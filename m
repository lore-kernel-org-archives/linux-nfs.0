From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Sat, 5 Aug 2006 09:36:58 +1000
Message-ID: <17619.55834.927259.225840@cse.unsw.edu.au>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G99E9-0002E2-OH
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 16:37:13 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G99E9-0002HV-Pl
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 16:37:14 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Friday August 4
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

On Friday August 4, gnb@melbourne.sgi.com wrote:
> 
> Neil, a headsup: this hunk clashes with one in the server large
> wsize patch, and will require minor and obvious manual adjustment.
> 
Ack.


> > I don't recall the history of /proc/sys/fs -- is there also a
> > /proc/sys/fs/nfsd directory, 
> 
> No.
> 
> > and wouldn't it be better to add this
> > particular sysctl in there?
> 
> I'd be happy to see such a thing.  One of my pending patches adds
> serverside sysctls; it feels wrong putting them in /proc/sys/fs/nfs/.
> OTOH that directory already has four serverside NLM entries that
> people do use.

And all those nlm tunables are in
   /sys/module/lockd/parameters/
as well.

So here is the question.  Should nfsd tunables go in
 - /proc/sys/fs/something. ?
   I agree that /proc/sys/fs/nfs isn't the best place.
   An .../nfsd could be created ofcourse

 - /sys/module/nfsd/parameters/ ?
   I like this approach.  Believe it or not, 'nfsd' is not a
   filesystem.  It is a .... service?  So putting it under
   'fs' has always felt wrong.  And using the modules parameter
   approach makes it look more like a parameter to a module rather
   than a config for some filesystem...

 - The 'nfsd' filesystem.
   (which is mounted under /proc/fs ... I'm beginning to regret that
    name choice just a little, but there wasn't anywhere else
    obvious).
   This is probably best from a usability perspective - all nfsd stuff
   in the one place.

So of the three options - the one that I find it hardest to justify
if /proc/sys, which is what the original patch uses - sad.

Other opinions on which is best?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
