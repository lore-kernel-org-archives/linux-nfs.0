From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH kNFSd 001 of 4] fix setattr-on-symlink error return
Date: Fri, 14 Oct 2005 08:29:56 -0400
Message-ID: <434FA4C4.6010806@redhat.com>
References: <20051014122041.11376.patches@notabene> <1051014022307.11542@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQOhH-0002G4-Ug
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 05:30:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQOhH-0007Jm-LP
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 05:30:03 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <1051014022307.11542@cse.unsw.edu.au>
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

NeilBrown wrote:

>This is a somewhat cosmetic fix to keep the SpecFS validation test
>from complaining.
>SpecFS want's to try chmod on symlinks, and ext3 and reiser (at least)
>return ENOTSUPP.
>Probably both sides are being silly, but it is easiest to simply make
>it a non-issue and filter out chmod requests on symlinks at the nfsd level.
>

Wouldn't it be better to fix the testsuite to not do this?  Doesn't the
testsuite also fail when run against ext3 and/or reiser file systems?

This is just overhead which will slow the NFS server a tiny bit.

Just out of curiosity, how does the testsuite even generate a chmod(2)
request on a symbolic link?  The chmod(2) system call semantics should
not allow this.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
