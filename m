From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Add support for quoted mount options
Date: Tue, 20 Mar 2007 14:29:32 +1100
Message-ID: <17919.21788.88716.596344@notabene.brown>
References: <20070319200240.GI18681@petra.dvoda.cz>
	<17919.1986.197057.221467@notabene.brown>
	<20070320002104.GA3288@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Karel Zak <kzak@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTV2e-0006hQ-HU
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 20:29:44 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTV2f-0008T9-6c
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 20:29:46 -0700
In-Reply-To: message from Karel Zak on Tuesday March 20
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

On Tuesday March 20, kzak@redhat.com wrote:
> On Tue, Mar 20, 2007 at 08:59:30AM +1100, Neil Brown wrote:
> > On Monday March 19, kzak@redhat.com wrote:
> > > The patch avoid the collision between commas in security contexts and the
> > > delimiter between mount options.
> 
>  The patch has been already sent by Steve Dickson and we already
>  talked about it few weeks ago. There was problem with some extra
>  space allocated for extra_opts. This version of the patch is more
>  clean from nfs-utils point of view.

Yes, the code is cleaner, thanks for that.

> 
> > > Try:
> > > 	mount.nfs foo://mnt/bar /mnt/bar -o context=\"aaa,bbb,ccc\",ro
> > 
> > Hmmm..... I'm feeling a bit uncomfortable about this.
> > Lots of code (well, some at least) relies on 'hasmntopt' which does
> > simple parsing of the option string looking for commas.  If we allow
> > commas to be embedded in options, that code can potentially get
> > confused.
> > 
> > Also, this code does not allow a double-quote to appear in the context
> > string.  You can have two (or 4 or any even number) but not one.
> > Could that ever be a problem?
> 
>  I don't think so. The linux kernel supports quotes *only* for SELinux
>  contexts and there is not possible use any nested quotes or anything
>  more creative. It's always something like:
> 
>     context="system_u:object_r:iso9660_t:s0:c1,c3,c4"
> 
>  It's kernel who has care about exact format. We need to push
>  the context string through mount.nfs to kernel only.

Of course when it comes through mount.nfs all the kernel sees is

           system_u:object_r:iso9660_t:s0:c1,c3,c4

> 
> > What exactly is this context string anyway?  Current kernels don't
> > seem to use it at all.  Presumably the code to use it is still in
> > development?   Is it some sort of security token? 
> 
>  That's already in Linus's tree, released in 2.6.19. See:
> 
>  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=3528a95322b5c1ce882ab723f175a1845430cd89

That patch seems fairly separate to this issues as it is stripping
quotes, and when the string comes via nfs, the quotes are already
stripped.

However it does seem to imply a precedent that commas within mount
options are to be accepted, and while I still that is a very dumb
idea, it isn't something worth fighting very hard for.

If it gets widely used and becomes a problem, maybe hasmntopt with get
"enhanced" to understand quotes ... though I suspect it would end up
just being a hack in util-linux that no-one else would benefit from.

I don't suppose I could convince you to write a 'hasmntopt'
replacement which works properly when there are quotes in the option
list, and get it into glibc :-?

> 
> > But if we can avoid commas altogether, that would be best.
> 
>  Probably to late... the format of selinux context string is generic,
>  it's nothing specific for a mount process. There are libs, kernel
>  and many utils that use this format.

We could still quote commas as \054 when they appear in mount options,
but I suspect I'm fighting a loosing battle.

I'll apply the patch.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
