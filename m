From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fix NFS mount.nfs options v4
Date: Mon, 7 Aug 2006 16:59:57 +1000
Message-ID: <17622.58605.231398.7539@cse.unsw.edu.au>
References: <44CA32CE.9030205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9z5u-0003ju-FK
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 00:00:10 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9z5t-0000MU-OD
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 00:00:11 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: message from Amit Gud on Friday July 28
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

On Friday July 28, agud@redhat.com wrote:

Sorry for the delay in reviewing this.
> 
> If the 'user' or 'users' mount option is specified on commandline, verify with 
> /etc/fstab if it is really specified. Setuid bit is still ON and should remain
> ON since mount drops the root privileges.
> 
> I've given this patch a good hammering, but not exhaustive by any means.

I still don't see this as being adequately secure.
All you are checking is whether the user has permission to mount onto
the given directory, or from the given server:/directory, but not if
they are allow to mount that server on that directory, or what options
are required.

e.g. /etc/fstab could say you are only allowed to mount with
noexec,nosuid, but mount.nfs isn't enforcing that.

It seems to me that if getuid() returns non-zero, then you have to 
either ignore or check everything given on the command line.

i.e.
  find the entry in /etc/fstab which has the same mointpoint and the
  same 'special' (server:/path).
  Make sure the options in /etc/fstab have an appropriate user or
  users entry.
  Use the options from /etc/fstab and ignore the options on the
  command line.

Does that sound fair?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
