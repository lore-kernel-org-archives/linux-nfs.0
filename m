From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 15:26:40 -0400
Message-ID: <20050920192640.GD31948@fieldses.org>
References: <20050920011046.23A07F4@dead.void.org> <20050920012525.GA26729@fieldses.org> <432FFFC7.7010803@redhat.com> <20050920183054.BCB62F4@dead.void.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHnlW-00045e-9e
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 12:26:54 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHnlU-0004Q5-RN
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 12:26:54 -0700
To: Steven <steven@void.org>
In-Reply-To: <20050920183054.BCB62F4@dead.void.org>
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

On Tue, Sep 20, 2005 at 11:30:54AM -0700, Steven wrote:
> I agree.  I don't think it is a good policy to tell the client that all
> of the data was written when some was not.
> 
> For what it's worth, the RFC says that if the write size exceeds wtmax
> then the server may write only wtmax bytes of the request.

OK.  Could you regenerate that patch with diff -up?  (See
Documentation/SubmittingPatches.)  Don't bother sending the modified
function, it's the patch that people want.

--b.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
