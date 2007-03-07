From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 09:37:18 +1100
Message-ID: <17903.16030.26119.464793@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4lB-0006lr-Jx
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:37:25 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP4lD-0002Wd-6B
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:37:27 -0800
In-Reply-To: message from J. Bruce Fields on Wednesday March 7
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

On Wednesday March 7, bfields@fieldses.org wrote:
> 
> Well, non-head-hurty ideas always welcomed.  I've got two export-related
> problems to fix:
> 
> 	- Our current NFSv4 pseudofs fsid=0 hack is a pain to administer
> 	  and results in inconsistent paths across different NFS
> 	  versions.

You've got to put that v4 pseudo root somewhere...
It just needs cleverness in nfs-utils to auto-bind-mount things into
the pseudoroot...  but I guess people cannot magically unmount things
then.

How about this.  We add an export option "follow-symlinks" so that
when nfsd is asked to stat a symlink it does a 'stat' instead of an
'lstat' (effectively).
Then we get mountd to make a tmpfs in /var/lib/nfs/pseudoroot which
contains directories and symlinks to the various export points names
in etab.  This tmpfs is exported as fsid=0,follow-symlinks.

Problem solved?

Ofcourse if different clients get to see different exports, then we
might need multiple tmpfs's in /var/lib/nfs/pseudoroot/$CLIENT/ ....

> 
> 	- The trick of using the pseudoflavor as a client name (so doing
> 
> 		/export	 gss/krb5(rw)
> 	
> 	  instead of
> 
> 		/export *(sec=krb5,rw)
> 
> 	  ), is inconsistent with what other os's do, and makes it
> 	  impossible to specify restrictions based both on flavor and on
> 	  ip network/dns name/netgroup.

Yeeesssss.  If you are using crypto-security, then the
source-ip-address (which is a terribly weak form of security) should
be irrelevant.  But I think you've convinced me that some people have
valid cases for the combined tested.  Grumble Grumble ;-) 

> 
> While I'm at it Trond and Christoph and others seem to be asking whether
> we can't make some more fundamental changes, such as:
> 
> 	- Maintaining a static in-kernel exports table instead of
> 	  loading it on demand from mountd, and
> 

Don't like that idea at all.  Demand-loading is a good thing.

> 	- divorcing the exports namespace completely from any local
> 	  process namespace, to the extent that you could even just say
> 	  "I want to export /dev/sda7 as /usr/local/bin" without first 
> 	  mounting /dev/sda7 someplace.

I like that even less.  Much much less.  Way way way less.  Yuck.

Having a private name-space for nfsd and co might be OK, but that is
the closest I could come to the above suggestion, and even then I'm not
convinced.  I think private name spaces are a very powerful tool that
should be used very very carefully.  There is plenty of room for
confusion of the poor sysadmin if you start doing too much with
private name spaces.

If you built a system where every daemon has a private namespace, then
having one for nfsd would be ok, but it really should be a system wide
approach to management, not an approach only used by nfsd.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
