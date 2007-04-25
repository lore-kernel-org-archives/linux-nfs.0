From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 25 Apr 2007 11:59:19 -0400
Message-ID: <20070425155919.GA22268@fieldses.org>
References: <46156F3F.3070606@redhat.com> <20070425141818.GA14729@fieldses.org>
	<462F6157.7060604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgjto-0000Gh-FV
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 08:59:20 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hgjtq-0006C5-KW
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 08:59:23 -0700
In-Reply-To: <462F6157.7060604@redhat.com>
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

On Wed, Apr 25, 2007 at 10:10:31AM -0400, Wendy Cheng wrote:
> The detailed overall steps were described in the first email we sent 
> *long* time (> 6 months, I think) ago. The first step of the whole 
> process is tearing down the floating IP from the failover server. The IP 
> is not accessible until filesystem is safely fail-over and SM_NOTIFY 
> ready to be sent.

I understand, thanks.

> Last round of discussion gave me an impression that as long as I rebased 
> the code into akpm's mm tree, these patches would get accepted. So I 
> have been quite careless in this submission and just realized people 
> have a very short memory :) .. Will do the write-up and put it somewhere 
> so we don't need to go thru this again.

Yeah, apologies for the short memory.  I'll try to follow more closely
from now on!

If practical, it would be helpful to have any such documentation in the
final version of the patches, though, either as patch comments or (maybe
better in this case) as comments in the code or in Documentation/.  When
someone needs to go back and find out how this was all meant to work,
it'll be easier to find in the source tree or the git history than in
the mail archives.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
