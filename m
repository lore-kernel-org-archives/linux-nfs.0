From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] unfsd: fix invalid argument error for
	setattr	request
Date: Thu, 16 Aug 2007 09:33:50 -0400
Message-ID: <20070816133350.GB9941@fieldses.org>
References: <Pine.LNX.4.64.0708160843060.10107@maggie.lkpg.cendio.se>
	<200708160751.AA00238@paprika.lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter_Astrand <astrand@cendio.se>, nfs@lists.sourceforge.net
To: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILfU1-0000eS-Kt
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 06:33:56 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILfU4-00028k-NI
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 06:33:58 -0700
In-Reply-To: <200708160751.AA00238@paprika.lab.ntt.co.jp>
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

On Thu, Aug 16, 2007 at 04:51:01PM +0900, Ryusuke Konishi wrote:
> Hi,
> 
> On Thu, 16 Aug 2007, Peter_Astrand wrote:
> >On Thu, 16 Aug 2007, Ryusuke Konishi wrote:
> >> Hi folks, 
> >> 
> >> I found that the Linux user-space NFS server (unfsd) fails
> >> for setattr requests against the kernel 2.6.22 and later.
> >
> >Hi, I'm curious: Why are you using this old unfsd instead of the kernel 
> >based knfsd, or the modern userspace implementation "unfs3"?
> 
> I am using both unfsd and knfsd because Debian still offers both.
> (It also offers unfs3 but I didn't notice until you let me know)
> 
> >As far as I understand, noone is maintaining the old unfsd anymore. 
> >
> >
> >Regards, 
> 
> All right.
> As you say, the mail to unfsd maintainers was returned by
> Host unknown. (Sigh)
> It seems to have little hope to modify unfsd for this. 

Have you tried the debian bug-tracking system?  Maybe they're
practically speaking the only maintainers that unfsd has now.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
