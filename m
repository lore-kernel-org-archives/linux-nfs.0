From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: LTP ustat01 test fails on NFSROOT
Date: Tue, 23 Oct 2007 21:21:34 -0400
Message-ID: <1193188894.27073.20.camel@heimdal.trondhjem.org>
References: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkUvL-0006EC-Pk
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 18:20:45 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkUvR-0007MO-04
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 18:20:49 -0700
In-Reply-To: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
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


On Tue, 2007-10-23 at 17:52 -0500, Kumar Gala wrote:
> I'm looking into an issue with LTP's ustat01 & ustat02 tests in which  
> they report the following:
> 
> ustat01     1  FAIL  :  ustat(2) failed and setthe errno to 116 :  
> Stale NFS file handle
> ustat02     2  FAIL  :  ustat(2) failed to produce expected error;  
> 14, errno: EFAULT and got 116
> 
> It appears sometime between 2.6.21 and 2.6.22-rc1 some changes to NFS  
> got introduced that cause this.
> 
> was wondering about any ideas while I try to debug what's going on.
> 
> thanks
> 
> - k

I'm seeing zero problems with the latest checkouts from Linus' git tree.
Mind giving us some more details?

'strace' output would be useful, as would the standard NFS list of
client mount options, server export options, details on how your
exported partition is set up on the server, etc...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
