From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH kNFSd 0 of 18] Introduction
Date: Fri, 24 Sep 2004 15:40:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16723.45901.829259.506439@cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
	<20040923215541.4369ca38.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAiow-0008KH-B8
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 22:40:38 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAiov-00028a-JJ
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 22:40:38 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Thursday September 23
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

On Thursday September 23, akpm@osdl.org wrote:
> NeilBrown <neilb@cse.unsw.edu.au> wrote:
> >
> > Subject: [PATCH kNFSd 1 of 18] nfsd4 fix: nfsd oopsed when encountering a conflict with a local lock
> >  Subject: [PATCH kNFSd 2 of 18] separate a little of logic from fh_verify into new function
> >  Subject: [PATCH kNFSd 3 of 18] nfsd4: don't take i_sem around call to ->getxattr
....
> 
> Which if any of these do you think are 2.6.9 material?

That depends on your criteria, but I suspect none of them are.  While
some of them do fix real bugs, NFSv4 is very much a work-in-progress
and people should expect bugs.  I don't feel that any are particularly
more urgent than any others.

If we really are in the "release candidate" phase, then leave them
until we enter the "pre" phase .... except that I'm not sure if "pre"
exists any more.

Thanks,
NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
