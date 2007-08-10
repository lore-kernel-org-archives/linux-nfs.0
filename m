From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/5] Enable text-based NFS mounts
Date: Fri, 10 Aug 2007 11:51:51 +1000
Message-ID: <18107.50359.957289.693302@notabene.brown>
References: <20070809212708.16767.6031.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJJfV-0008Lw-DG
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:52:01 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJJfZ-0004SL-3r
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:52:05 -0700
In-Reply-To: message from Chuck Lever on Thursday August 9
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

On Thursday August 9, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Enough people have been pushing me to publish this that I finally stopped
> procrastinating and hacked something together.
> 
> Here are a couple of clean-ups, and two patches that provide a command line
> option on mount.nfs to force it to pass string mount options instead of binary
> mount options to the kernel.

I've taken patches 2 and 3...

> 
> I'd like to get these integrated into nfs-utils now in order to make it easy
> for people to start testing the kernel logic; and because Trond wants to
> freeze the mount ABI, so the only way to add new options is with a new string-
> based option.
> 
> The stropt.[ch] files are rather unfinished, but are in good enough shape that
> they can be used now and improved by everyone as we go along.  The command
> line option makes it so that normally mount.nfs will use the legacy binary
> options, and not accidentally pass text-based options; thus it is safe to
> install as a system's default /sbin/mount.nfs.

Unfortunately a little too unfinished.  Once you've fixed the strtok
usage I'll take them.

> 
> As the second patch says, when we are all happy with the user space and kernel
> parts of this, it will be easy enough to replace the command line option with
> a switch based on the kernel version.

Agreed.. though Trond's suggested of disabling -i for early kernel
versions is a good one.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
