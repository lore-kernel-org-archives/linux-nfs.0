From: Open Source <opensource3141@yahoo.com>
Subject: Re: "mount: File exists" when trying to mount a second krb5
	volume!
Date: Thu, 16 Nov 2006 07:21:59 -0800 (PST)
Message-ID: <20061116152159.63878.qmail@web58107.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkj44-0007UY-O2
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 07:22:08 -0800
Received: from web58107.mail.re3.yahoo.com ([68.142.236.130])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gkj45-0004RP-Mo
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 07:22:10 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
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

Hi Bruce,

Sure.  It was a bit frustrating learning the sysctl debug
infrastructure for the first time and weeding through
the code to add more debug statements, but I'm glad
I got to the bottom of things.

Please let me know if there is a quick fix for this
problem.  It would be idea to get this into the
main kernel tree as soon as possible.

Thanks again,
Paarvai

----- Original Message ----
From: J. Bruce Fields <bfields@fieldses.org>
To: Open Source <opensource3141@yahoo.com>
Cc: nfsv4@linux-nfs.org; nfs@lists.sourceforge.net
Sent: Wednesday, November 15, 2006 7:51:29 PM
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!

On Wed, Nov 15, 2006 at 06:31:17PM -0800, Open Source wrote:
> Here's what is happening.

Thanks for your persistence!

> For the second mount to the same server, the rpc client is
> cloned and has the same path in /var/lib/nfs/rpc_pipefs/nfs
> has the first connection.  Therefore on step 3 the pipe creation
> fails in net/sunrpc/auth_gss/auth_gss.c.  This causes the
> entire mount to fail.

Argh, I could swear we've tried to fix this problem at least twice
before....

> This is a serious bug that prevents important functionality
> of nfsv3 with krb5.  I notice that kernel 2.6.19 is on release
> candidate 5.  Is there any way a surgical fix can be inserted
> into 2.6.19 before final release?

I'll take a look tommorow if someone else doesn't beat me to it, but I
doubt we'll get it done that fast.

--b.






-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
