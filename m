From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to
	listen	on a privileged port??
Date: Thu, 26 Apr 2007 16:32:07 +1000
Message-ID: <17968.18279.424773.589417@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251356.35926.okir@lst.de> <462F7769.4080304@redhat.com>
	<200704252214.03069.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgxWi-0003FM-4i
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 23:32:24 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HgxWj-0006YK-9w
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 23:32:26 -0700
In-Reply-To: message from Olaf Kirch on Wednesday April 25
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

On Wednesday April 25, okir@lst.de wrote:
> 
> I don't say tirpc is bad. What I say is, it's better to handle this the way
> we deal with changes to the kernel: start with what you have, and
> which you know works well. Add to it, until you have the functionality
> you want. On the way, you may find out there's better ways of
> solving things that you anticipated. If you run into sudden problems,
> you can bisect.
> 

Following this logic, should we add rpcbind functionality to portmap
rather than throw it out and start with something less known???

I'd have to read up more on rpcbind before I could have an opinion on
that.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
