From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 11:08:24 -0400
Message-ID: <20050915150824.GA24870@fieldses.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Stockheim <tommi@bub-agema.de>,
	Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFvLu-0006ht-5o
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:08:42 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFvLp-0005LD-PM
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:08:42 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com>
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

On Thu, Sep 15, 2005 at 06:50:49AM -0700, Lever, Charles wrote:
> close-to-open is a convention, not a specification, so it's really up to
> the client developers to implement what they think is right.

You can't turn off cache revalidation checks while someone else on the
client has the file open.  Wouldn't that would make close-to-open
useless in a lot of cases?

--b.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
