From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Enable text-based mounts in mount.nfs
Date: Tue, 13 Nov 2007 10:11:35 -0500
Message-ID: <4739BEA7.1030803@RedHat.com>
References: <20071112172835.3134.36815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrxVk-0002O8-JQ
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:17:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IrxVq-0005Rk-02
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 07:17:14 -0800
In-Reply-To: <20071112172835.3134.36815.stgit@localhost.localdomain>
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



Chuck Lever wrote:
> Hi Steve-
> 
> Sorry for posting a single patch with a cover letter (a practice normally
> frowned upon).
> 
> Here's the mount.nfs change that makes text-based NFS mounts the default,
> deprecating the old legacy mount ABI for 2.6.23 kernels and later.  It's
> best to get this into the code base for people to start using long before
> you plan to cut a new release of nfs-utils.
> 
> Text-based NFS mounts, as you know, are required to enable several upcoming
> advanced NFS features, such as IPv6 support, NFS over RDMA, and local disk
> caching.  It will also make it simple to add support for new NFS mount
> options.
> 
> The 2.6.23 kernel's text-based NFS mount support works for many basic
> configurations.  There are some regression nits that are cleaned up in
> 2.6.24.
Ok..
> 
> Btw, will you continue hosting the nfs-utils git repository on
> linux-nfs.org?
Yes... I'm a bit behind atm... but I plan on catching up this week...

steved.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
