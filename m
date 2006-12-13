From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Wed, 13 Dec 2006 08:17:43 -0500
Message-ID: <457FFD77.6070507@redhat.com>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>	<45704A4A.6000007@poochiereds.net>	<17779.42545.642976.873602@cse.unsw.edu.au>	<4574392D.9080807@poochiereds.net>	<17788.44467.578376.702580@cse.unsw.edu.au>	<457CD334.6080700@redhat.com>
	<17790.229.867008.833159@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuTyE-0006OD-GG
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 05:16:26 -0800
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuTyF-00081T-El
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 05:16:27 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17790.229.867008.833159@cse.unsw.edu.au>
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
 >
 > Does that make sense?

Yes. Thanks for explaining that -- it makes total sense now. I was focusing
on auth_authenticate, which I don't think would behave differently, but you're
clearly correct that we'd need to ensure the same for the kernel caches.

 >> As you said, neither the rmtab or the kernel cache is an ideal place to pull
 >> this info. So, my inclincation is to stick with the rmtab, and simply have it
 >> track what we know is trackable -- mount and unmount calls into mountd. I
 >> think having false positives is preferable to possibly having some mounts
 >> that are not reflected at all because they have gone idle.
 >
 > Ok, how about this as a way forward.
 >
 >  1/ remove that 'my_client' caching.
 >  2/ Remove the updates of rmtab on client upcalls and simply do rmtab
 >     updates with hostname (from get_reliable_hostbyaddr) and path name
 >     from MOUNT or UMOUNT requests
 >  3/ Add -I flag which:
 >       passes IP address rather than client_compose name to kernel and
 >       adds rmtab entries on kernel upcalls.  It also hard-removes
 >       rmtab entries on 'UMOUNT' and flush the kernel cache so that the
 >       next access for that host/path causes an upcall.
 >  4/ Add a -? flag (haven't chosen a letter yet) which:
 >       implies -I, but when asked for a 'DUMP', it calls gethosytbyname
 >       on each IP address to ge a hostname.
 >
 > Then the default would be vaguely usable, and more precise information
 > would be available (at a cost).
 >

At first glance, that sounds reasonable. I'll have a closer look at the code
and your idea and see if I can come up with a patch.

 >> Either way, a manpage update is probably also in order to outline the folly
 >> of depending on showmount -a :-).
 >
 > Yes, I would happily accept a patch making such a change.
 >

Once we come to consensus on a code patch, I'll have a look at what manpage
changes need to be made.

Thanks,
Jeff


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
