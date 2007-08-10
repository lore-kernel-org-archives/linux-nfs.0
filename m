From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/5] mount.nfs: Add new files for supporting
	string-ified	mount options
Date: Fri, 10 Aug 2007 11:46:36 +1000
Message-ID: <18107.50044.333597.209861@notabene.brown>
References: <20070809213706.16767.89918.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJJaS-0007oh-KQ
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:46:48 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJJaU-0002gq-L0
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:46:52 -0700
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
> Introduce support files which contain code that builds string mount
> options and passes them to the kernel.  This is a pre-requisite for
> actually enabling /sbin/mount.nfs to do text-based mounts.
> 
> This is only partially complete at the moment, but is presented so that
> folks can start banging on the kernel mount option string parsing code.
> There are clearly still parts that are not implemented quite yet, such
> as bg and retry support, but it should be enough to get going.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

> +
> +static int retry_opt = 10000;		/* 10,000 minutes ~= 1 week */

Why one week?  Why no "MAX_INT"? retry_opt is never actually used, so
I cannot guess.
Neither is bg_opt, but you did say it was incomplete.

> +static int bg_opt = 0;
...

> +
> +/*
> + * Walk through our mount options string, and indicate the presence
> + * of 'bg', 'retry=', and 'clientaddr='.
> + */
> +static void extract_interesting_options(char *opts)
> +{
> +	char *opt, *opteq;
> +	int val;
> +
> +	for (opt = strtok(opts, ","); opt; opt = strtok(NULL, ",")) {

Do you really want to use 'strtok'?  It modifies the 'opts' argument,
so where you go to use it later, you cannot be sure that it is still
the same (all the ','s will be turned to nuls).

I'm surprised that this works at all... I'd better go test it....

OK, it doesn't work.

I run

   mount.nfs host:/path /mnt -i -v -o bg,ro,something=whatever
and it says:

  mount.nfs: using C string mount system call interface
  mount.nfs: option string is 'bg,addr=192.168.1.10'
  mount.nfs: Invalid argument

so the 'ro' and the 'something=whatever' don't make it to the kernel.

I'm happy to take the patch before it is complete, but I think at
least this bit needs to work as expected before it goes into
nfs-utils....

Thanks,

NeilBrown

   

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
