From: Steven <steven@void.org>
Subject: Re: Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 11:30:54 -0700
Message-ID: <20050920183054.BCB62F4@dead.void.org>
References: <20050920011046.23A07F4@dead.void.org> <20050920012525.GA26729@fieldses.org>  <432FFFC7.7010803@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Steven <steven@void.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHmuB-0001YS-CY
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 11:31:47 -0700
Received: from dsl092-218-023.sfo2.dsl.speakeasy.net ([66.92.218.23] helo=chaotic.void.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHmu6-0000Xx-Uq
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 11:31:47 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: Message from Peter Staubach <staubach@redhat.com>
   of "Tue, 20 Sep 2005 08:25:43 EDT." <432FFFC7.7010803@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> This would be a bug in the client, but if the server is going to attempt
> to write some of the data anyway, then it should correctly report the
> number of bytes written.  Otherwise, the server should reject the entire
> request.

I agree.  I don't think it is a good policy to tell the client that all
of the data was written when some was not.

For what it's worth, the RFC says that if the write size exceeds wtmax
then the server may write only wtmax bytes of the request.

--Steven


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
