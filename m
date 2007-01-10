From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS and 'intr' mount option problems in 2.4 kernel
Date: Tue, 09 Jan 2007 20:53:06 -0500
Message-ID: <1168393986.6061.26.camel@lade.trondhjem.org>
References: <92cbf19b0701081042l145e54cx8053d50a2b5871e2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4SeY-0003kL-QT
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 17:53:23 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/+TQRunFRMzZYOKFBwki1SHR3c/MRh9Bs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H4SeZ-0007AZ-9a
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 17:53:24 -0800
To: Chakri n <chakriin5@gmail.com>
In-Reply-To: <92cbf19b0701081042l145e54cx8053d50a2b5871e2@mail.gmail.com>
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

On Mon, 2007-01-08 at 10:42 -0800, Chakri n wrote:
> I think most of these problems have been addressed in 2.6, but if we
> want to fix some of the issues in 2.4 for those like me who are still
> using 2.4, are there any side effects using "wait_event_interruptible"
> in place of "__wait_event" or adding "timer" to tasks waiting on
> "pending_queue"?

Sorry, but as far as I'm concerned 2.4.x is in "stability fixes only"
mode. I'm not going to approve any changes that don't fix an Oops, a
data corruption issue or a security issue.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
