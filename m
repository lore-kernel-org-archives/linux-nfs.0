From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Wed, 4 Aug 2004 16:14:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804201411.GL19282@fieldses.org>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040802103905.GI25023@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsS9S-0001bn-Ob
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 13:14:18 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BsS9S-0007IW-Bh
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 13:14:18 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040802103905.GI25023@suse.de>
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

On Mon, Aug 02, 2004 at 12:39:05PM +0200, Olaf Kirch wrote:
> On Tue, Jul 13, 2004 at 11:17:59AM -0400, J. Bruce Fields wrote:
> > But you could exactly the same thing by recording the values at the
> > beginning of the test run and then subtracting.  In practice this is
> > likely to be annoying, so you'd want to write utilities that did this
> > for you, like say
> > 
> > checkpoint_stats stats.txt
> > display_stats --since stats.txt
> 
> But it sucks. I had folks run something like 12-15 performance
> measurements and take the NFS stats, and it was a huge mess to sort
> through.  Telling folks "use nfsstat -z to wipe stats before each
> command" is much easier.

Well, like I say, we could implement "nfsstat -z" by checkpointing as
above but just writing to a file at some default path, though admittedly
the choice of path might not be obvious.

Having nfsstat just hang around till it's signaled (like tcpdump does)
would also be easy.

> Besides, -z is sort of a standard option, so we might as well
> implement it.

Well, OK, I suppose that's an argument for it.--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
