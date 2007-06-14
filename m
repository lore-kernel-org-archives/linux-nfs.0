From: John McCorquodale <mcq@cacr.caltech.edu>
Subject: Re: 100% repeatable NFS v3 client hang
Date: Thu, 14 Jun 2007 11:09:12 -0700
Message-ID: <20070614180912.GC1915@danse.us>
References: <20070614165550.GB1454@danse.us>
	<1181844218.6957.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hytkj-0000gv-BX
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:09:01 -0700
Received: from danse-head.cacr.caltech.edu ([131.215.145.66]
	helo=w0.cacr.caltech.edu)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hytkm-0005V8-7y
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:09:04 -0700
In-Reply-To: <1181844218.6957.32.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

> 2.6.21 still had some problems, but 2.6.22-rcX has fixes for all
> reported bugs and should be stable. At least I haven't heard of any
> further issues.
> 
> If you can reproduce the hang, and send me the output from an 'echo t
> >/proc/sysrq-trigger', then I'd be happy to look at the resulting dump.
> Don't forget to specify a large buffer size when you use dmesg: I tend
> to use 'dmesg -s 90000'.
> It would also be nice if you could try to reproduce the problem on a
> 2.6.22-rc4 kernel, to see if it is still there.

Will do as you instruct.  It'll probably be the weekend before I can get the
shadow systems running for our experiments.  I was running 2.6.22-rc3 at
one point and saw the problem, so we'll probably get something interesting
from the sysrq.

Thanks for the precise insturctions; that's about the right level of detail
for my inexperience doing this sort of thing.  :)

Cheers,

-mcq

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
