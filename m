From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] NFS client fixes for 2.6.23++
Date: Fri, 19 Oct 2007 19:57:12 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710191953230.3794@woody.linux-foundation.org>
References: <200710200244.l9K2i1ik016752@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ij4Wg-0000U3-9n
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:57:22 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ij4Wk-0005U3-KS
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:57:27 -0700
In-Reply-To: <200710200244.l9K2i1ik016752@agora.fsl.cs.sunysb.edu>
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



On Fri, 19 Oct 2007, Erez Zadok wrote:
> 
> i386

Hmm. Doesn't happen here, not on x86-64 nor i386.

Probably some subtle config issue as usual, where some configuration 
doesn't include <sched.h> indirectly.

But I'll add the direct includes of <linux/sched.h> and <linux/wait.h>. 

		Linus

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
