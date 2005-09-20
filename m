From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Minor problem in nfsv3 write
Date: Mon, 19 Sep 2005 21:25:25 -0400
Message-ID: <20050920012525.GA26729@fieldses.org>
References: <20050920011046.23A07F4@dead.void.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHWt0-0004cC-2d
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 18:25:30 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHWsy-0002Rd-Jz
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 18:25:29 -0700
To: Steven <steven@void.org>
In-Reply-To: <20050920011046.23A07F4@dead.void.org>
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

On Mon, Sep 19, 2005 at 06:10:46PM -0700, Steven wrote:
> 
> There is a minor bug in the way writes are handled in nfs3.  If the
> client requests a write for more than 32k of data the server will only
> write 32k but report that it wrote the whole amount.

Our server also reports 32k as the maximum write size.  So the bug is on
the client side here, isn't it?

--b.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
