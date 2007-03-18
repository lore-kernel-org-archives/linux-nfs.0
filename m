From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 01/11] nfs-utils: mount: non-nfs mount options
Date: Mon, 19 Mar 2007 10:41:40 +1100
Message-ID: <17917.52788.9258.451246@notabene.brown>
References: <45E2C1C1.9050302@RedHat.com>
	<17891.51711.148463.251589@notabene.brown>
	<45FAB6DC.6060706@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Amit Gud <gud@ksu.edu>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT50W-0005T4-Uv
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:41:49 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HT50X-0001CG-Kv
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:41:51 -0700
In-Reply-To: message from Steve Dickson on Friday March 16
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

On Friday March 16, SteveD@redhat.com wrote:
> 
> > 
> > and possible some other things that I didn't notice.  As this is a
> > setuid program, I really want to be able to review changes in
> > isolation please.
> Ok... I broke the original patch up into 3 separate ones.
> Pleas see attachments...

Thanks.  I've applied the last.
I'd really like to understand the ln/cp issue before applying.  And
I'm not quite ready to turn on setuid yet.  Maybe when I do that,
testing will show something.

The first patch - I have already applied that conceptually.. A lot of
the code is different as I wasn't very comfortable with what was
there.

e.g. When checking that a 'user' mount was in fstab, it just checked
that the mountpoint or filesystem was listed in fstab with the 'user'
flag. It didn't check that the mountpoint and filesystem and options all
matched.
So I think that if you put in fstab that  host:/place was allowed to
be mounted on /foo by any user, than any user could run mount.nfs
directly, ask for host:/place to be mounted on /etc and it would work.

My version is at 
  http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=ae5ec51e0ddc99dc5552e51bd5c095084dbb61aa

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
