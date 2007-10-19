From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Fri, 19 Oct 2007 09:41:16 -0400
Message-ID: <1192801277.7073.4.camel@heimdal.trondhjem.org>
References: <200710190549.l9J5nnX8007119@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iis5G-0003GX-Bv
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 06:40:14 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Iis5K-0004b6-GI
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 06:40:19 -0700
In-Reply-To: <200710190549.l9J5nnX8007119@agora.fsl.cs.sunysb.edu>
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


On Fri, 2007-10-19 at 01:49 -0400, Erez Zadok wrote:
> I'm testing unionfs on top of nfsv2/3/4, using 2.6.24 as of linus's commit
> 4fa4d23fa20de67df919030c1216295664866ad7.  A lot of my unionfs regression
> tests are failing on nfs2, b/c files that should be deleted, aren't.  It
> feels like there may be a ref leak that prevents the files from being
> deleted, or maybe an unlink issue.  It doesn't happen in all of my previous
> kernels w/ identical unionfs (code 2.6.9--2.6.23).  And in 2.6.24 it happens
> only w/ nfs2 -- nfs3/4 are fine.
> 
> I'm not sure if this is a client or server issue, and I'm only starting to
> dig deeper.  But I thought I'd ask you in case this is a known problem and
> you have a fix.  If this is the first you hear of this problem, let me know
> and I'll try to narrow it down further.

A couple of questions:

      * Are these files being sillyrenamed?
      * Are they shown as being removed by the server?

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
