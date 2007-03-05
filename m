From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Mon, 05 Mar 2007 17:03:02 -0500
Message-ID: <1173132182.6315.27.camel@heimdal.trondhjem.org>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOLGx-0007LR-HG
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 14:03:11 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOLGy-0005oI-Cf
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 14:03:13 -0800
In-Reply-To: <45EC8FD3.4010809@redhat.com>
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

On Mon, 2007-03-05 at 16:46 -0500, Peter Staubach wrote:
> It is an ickey idea and the right way is to fix the Tru64 server, but
> given that we probably can't get it fixed, this seems relatively low
> risk.

I disagree. The fact that people are using the fsid in creative ways, is
reason enough to be cautious about quick fixes. If we really must work
around on the client, then I'd prefer something like a mount option that
just causes us to ignore fsid changes (i.e. fall back to the 2.4.x
behaviour).

Hacking the fsid on behalf of the server is certainly vetoed.

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
