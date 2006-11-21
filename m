From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] various minor manpage fixes
Date: Tue, 21 Nov 2006 00:02:34 -0500
Message-ID: <1164085354.6377.37.camel@lade.trondhjem.org>
References: <20061120224752.GA13561@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmNmR-0000JY-Co
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 21:02:50 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18IK+9J93J/ItGO2Gwwji0/QnnuZj4U8oo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmNmS-00044B-64
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 21:02:48 -0800
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20061120224752.GA13561@uio.no>
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

On Mon, 2006-11-20 at 23:47 +0100, Steinar H. Gunderson wrote:
> Hi,
> 
> Here's another patch that has been sitting in our tree for a while, which
> should probably go in upstream. Changelog:
> 
> === snip ===
> Author: Steinar H. Gunderson <sesse@debian.org>
> Date:   Mon, 20 Nov 2006 23:46:32 +0100
> 
>     Use memset instead of __bzero. bzero has been deprecated
>     for years (and anything starting with __ is an internal
>     function anyhow), and __bzero seems to have broken on ia64
>     not too long ago.
> === snip ===

When sending in patches like this, could you please also add in a
'Signed-off-by' line as per the Developer's Certificate of Origin 1.1
(See Documentation/SubmittingPatches in the Linux kernel source).
Admittedly the patch you sent in was extremely unlikely to be subject to
any special intellectual property claims, but this is a matter of good
coding practice.

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
