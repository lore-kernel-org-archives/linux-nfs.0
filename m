From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: [GIT] NFS client fixes for 2.6.23++
Date: Fri, 19 Oct 2007 22:44:01 -0400
Message-ID: <200710200244.l9K2i1ik016752@agora.fsl.cs.sunysb.edu>
References: <alpine.LFD.0.999.0710191929340.3794@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Erez Zadok <ezk@cs.sunysb.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ij4Js-0007oD-D1
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:44:08 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ij4Jw-0002dD-Jr
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:44:13 -0700
In-reply-to: Your message of "Fri, 19 Oct 2007 19:32:13 PDT."
	<alpine.LFD.0.999.0710191929340.3794@woody.linux-foundation.org>
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

In message <alpine.LFD.0.999.0710191929340.3794@woody.linux-foundation.org>, Linus Torvalds writes:
> 
> 
> On Fri, 19 Oct 2007, Erez Zadok wrote:
> > 
> > Trond, with Linus's latest tree, you need to #include <linux/sched.h> in
> > fs/nfs/unlink.c, else I get:
> > 
> >   CC [M]  fs/nfs/unlink.o
> > fs/nfs/unlink.c: In function 'nfs_dec_sillycount':
> > fs/nfs/unlink.c:67: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
> ...
> 
> Hmm? Which architecture?

i386

Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
