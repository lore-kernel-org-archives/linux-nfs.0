From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Fri, 24 Sep 2004 16:58:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040924205858.GF29929@fieldses.org>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org> <20040917022015.GA15212@fieldses.org> <16721.8596.980204.899779@cse.unsw.edu.au> <20040923214644.GA19291@fieldses.org> <16723.40128.804230.618580@cse.unsw.edu.au> <20040924074209.GA18703@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAx9o-0000AB-TI
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 13:59:08 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CAx9n-0003ZW-Dc
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 13:59:08 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040924074209.GA18703@suse.de>
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

On Fri, Sep 24, 2004 at 09:42:09AM +0200, Olaf Kirch wrote:
> On Fri, Sep 24, 2004 at 02:04:16PM +1000, Neil Brown wrote:
> > Does anyone have objections to the following patch, which presumes the 
> > svcauth_unix_set_client patch from Bruce.  With it, locking starts
> > working again.
> 
> It looks to me as if the patch forgets to include the NULL verifier
> for those procedures that don't need authentication.
> 
> I think you also want to do the same in svcauth_null_accept, as some
> lockd implementations actually use AUTH_NULL.

Note that the place where the check is added is in
svcauth_unix_set_client, which (after my 2 svcauth_unix patches) is
called from both null_accept and unix_accept.  Both encode a NULL
verifier if svcauth_unix_set_client fails.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
