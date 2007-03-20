From: Karel Zak <kzak@redhat.com>
Subject: Re: [PATCH] Add support for quoted mount options
Date: Tue, 20 Mar 2007 01:21:04 +0100
Message-ID: <20070320002104.GA3288@petra.dvoda.cz>
References: <20070319200240.GI18681@petra.dvoda.cz>
	<17919.1986.197057.221467@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTS69-0004S3-SL
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 17:21:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTS67-0004WC-Ev
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 17:21:12 -0700
In-Reply-To: <17919.1986.197057.221467@notabene.brown>
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

On Tue, Mar 20, 2007 at 08:59:30AM +1100, Neil Brown wrote:
> On Monday March 19, kzak@redhat.com wrote:
> > The patch avoid the collision between commas in security contexts and the
> > delimiter between mount options.

 The patch has been already sent by Steve Dickson and we already
 talked about it few weeks ago. There was problem with some extra
 space allocated for extra_opts. This version of the patch is more
 clean from nfs-utils point of view.

> > Try:
> > 	mount.nfs foo://mnt/bar /mnt/bar -o context=\"aaa,bbb,ccc\",ro
> 
> Hmmm..... I'm feeling a bit uncomfortable about this.
> Lots of code (well, some at least) relies on 'hasmntopt' which does
> simple parsing of the option string looking for commas.  If we allow
> commas to be embedded in options, that code can potentially get
> confused.
> 
> Also, this code does not allow a double-quote to appear in the context
> string.  You can have two (or 4 or any even number) but not one.
> Could that ever be a problem?

 I don't think so. The linux kernel supports quotes *only* for SELinux
 contexts and there is not possible use any nested quotes or anything
 more creative. It's always something like:

    context="system_u:object_r:iso9660_t:s0:c1,c3,c4"

 It's kernel who has care about exact format. We need to push
 the context string through mount.nfs to kernel only.

> What exactly is this context string anyway?  Current kernels don't
> seem to use it at all.  Presumably the code to use it is still in
> development?   Is it some sort of security token? 

 That's already in Linus's tree, released in 2.6.19. See:

 http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=3528a95322b5c1ce882ab723f175a1845430cd89

> How often would it have commas?

 Unfortunately often in Multi-Category Security (MCS) SELinux:

 http://www.nsa.gov/selinux/list-archive/0609/17224.cfm


> How often would it have double-quote?  Would it be
> possible to use a different character than ',' - maybe ':' ???

 No, the format is exact.

> But if we can avoid commas altogether, that would be best.

 Probably to late... the format of selinux context string is generic,
 it's nothing specific for a mount process. There are libs, kernel
 and many utils that use this format.

> Can the context string even need to have a space in it?  That would be
> rather awkward to put in /etc/fstab etc I think.

 IMHO it's always without a space (I hope selinux guys aren't on crack ;-)

    Karel

-- 
 Karel Zak  <kzak@redhat.com>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
