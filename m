From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Tue, 06 Mar 2007 08:05:08 -0500
Message-ID: <1173186308.6393.7.camel@heimdal.trondhjem.org>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
	<45EC9837.1010504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOZM8-0002gj-EE
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 05:05:28 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOZM9-0007Ee-8K
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 05:05:30 -0800
In-Reply-To: <45EC9837.1010504@redhat.com>
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

On Mon, 2007-03-05 at 17:22 -0500, Peter Staubach wrote:
> Perhaps the right thing to do is to revert the NFSv2/NFSv3 support
> completely and not have them worry about changing fsids?  The common
> practice is to use an automounting facility or static mounts to
> construct namespaces for NFSv2/NFSv3 networks.  It is really only
> with the advent of NFSv4 that the fsids actually become interesting
> and something that the client needs to be aware of.

That is not quite true. It has been a problem on NFSv2/v3 ever since
IRIX introduced the 'nohide' export option (which was later copied by
the Linux server). There are only too many programs out there that are
easily fooled by the combination of hard links and non-unique inode
numbers.

> Or we could just punt and document that READDIRPLUS must be disabled
> on all Tru64 NFS servers if this problem is seen.

That would also be an option.

Cheers
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
