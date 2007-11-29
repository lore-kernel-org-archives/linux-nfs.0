From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Thu, 29 Nov 2007 00:30:30 -0500
Message-ID: <1196314230.7950.42.camel@heimdal.trondhjem.org>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
	<47434ED7.4010100@redhat.com>
	<47435049.1010800@redhat.com> <47445727.5090705@oracle.com>
	<474A3D6B.2060208@redhat.com> <20071126050230.GD21120@fieldses.org>
	<18254.19187.470275.538680@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, chuck.lever@oracle.com,
	nfs@lists.sourceforge.net, Wendy Cheng <wcheng@redhat.com>
To: NeilBrown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ixbz2-0004Rs-AO
	for nfs@lists.sourceforge.net; Wed, 28 Nov 2007 21:30:44 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ixbz7-0007dN-Nv
	for nfs@lists.sourceforge.net; Wed, 28 Nov 2007 21:30:50 -0800
In-Reply-To: <18254.19187.470275.538680-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Thu, 2007-11-29 at 16:15 +1100, NeilBrown wrote:
> On Monday November 26, bfields@fieldses.org wrote:
> > 
> > (Stupid question: what would it take to give NFS the equivalent to
> > COMMIT for directory operations?)
> 
> Interesting question.
> 
> I guess the granularity would have to be per-directory.  I think
> programs that need transactional behaviour for directory operations
> already need to call fsync on the directory, so that should be
> consistent with the current API.
> 
> If DIR_COMMIT says "sorry, the server crashed", you need to replay the
> directory operations, which might be tricky in a number of cases.
> e.g. how do you replay a CREATE and be sure of getting the same
> fileid?
> How can you replay an UNLINK and be sure you deleted the right file
> and not some other file that some other client created since your
> UNLINK.
> 
> It would probably be possible to manage something, but I don't think
> it would be as "simple" as COMMIT.

Actually, the real problem would be dealing with something like
unlink('foo') followed by open('foo', O_CREAT|O_EXCL). How do you ensure
that a replay of those actions following a reboot is fully consistent in
the face of some other client attempting an open('foo', O_CREAT) at the
same time?

The problem is that a number of directory operations involve exclusive
semantics, and so cannot be replayed. The solution to this sort of
problem is going to have to involve exclusive (i.e. write) directory
delegations to ensure that whatever transactions one client performs
cannot interfere with the transactions performed by another.

Trond


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

