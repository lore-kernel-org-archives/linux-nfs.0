From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Thu, 23 Sep 2004 17:46:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040923214644.GA19291@fieldses.org>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org> <20040917022015.GA15212@fieldses.org> <16721.8596.980204.899779@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAbQS-0004f3-2l
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 14:46:52 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CAbQQ-0001CL-LJ
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 14:46:52 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16721.8596.980204.899779@cse.unsw.edu.au>
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

On Wed, Sep 22, 2004 at 04:54:12PM +1000, Neil Brown wrote:
> Alternately, the code which causes a call-back to be meaningful
> (e.g. nlmclnt_lock in lockd (??)) could insert the relevant
> information into the auth cache in advance.

There's not really a reliable way to do that with the current code since
userspace can flush the auth_domain cache at whim.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
