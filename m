From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 01/11] nfs-utils: mount: non-nfs mount options
Date: Tue, 27 Feb 2007 17:04:47 +1100
Message-ID: <17891.51711.148463.251589@notabene.brown>
References: <45E2C1C1.9050302@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>, Amit Gud <agud@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLvTM-0002Ew-9O
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:06:00 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLvTN-0004iB-U9
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:06:02 -0800
In-Reply-To: message from Steve Dickson on Monday February 26
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

On Monday February 26, SteveD@redhat.com wrote:
> commit 806b02f63fe6e01946d84a1f14c74e977be76530
> Author: Amit Gud <agud@redhat.com>
> Date:   Sat Feb 24 14:31:13 2007 -0500
> 
>     Added the following non-nfs mount options as suggested
>     but upstream code reviews:
>     
>         [no]auto, [no]users, [no]user, [no]owner, [no]group
>     	    _netdev, comment

This patch does a lot more than that brief description suggests.

- The 'users' / 'user' changes are enough to be a patch in itself,
  particularly as it is a security issue and needs careful review.
  mount and umount do similar tests here and it would be good to
  include them in the library (nfs/fstab.c).

- 'const' is removed from nfs_mntent_s, and copy_mntent is introduced
  .. are those related?

- You copy instead of link the 4 different mount.* programs, which
  might be a good thing, but deserves a comment in the changelog.

- Some printf change to fprintf, which is good, but seems to be
  independent of the rest.

and possible some other things that I didn't notice.  As this is a
setuid program, I really want to be able to review changes in
isolation please.

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
