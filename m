From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/4] mount.nfs: mount's background daemon should
	free	"mount_point" properly
Date: Fri, 24 Aug 2007 13:11:03 +1000
Message-ID: <18126.19527.640133.608662@notabene.brown>
References: <20070821161902.4373.67197.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOPZl-00008C-4r
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 20:11:09 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOPZp-0008AM-7Z
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 20:11:13 -0700
In-Reply-To: message from Chuck Lever on Tuesday August 21
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

On Tuesday August 21, chuck.lever@oracle.com wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/mount.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index d299358..40e7958 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -557,7 +557,7 @@ int main(int argc, char *argv[])
>  
>  		/*
>  		 * Parent exits immediately with success.  Make
> -		 * sure not to free "mount_point"
> +		 * sure parent doesn't free "mount_point".
>  		 */

I certainly agree that this comment could be improved.   I don't think
your change improves it.  I think I'll just remove the second sentence.

>  		if (fork() > 0)
>  			exit(0);
> @@ -568,6 +568,7 @@ int main(int argc, char *argv[])
>  		if (verbose && mnt_err)
>  			printf(_("%s: giving up \"%s\"\n"),
>  				progname, spec);
> +		free(mount_point);
>  		exit(0);
>  	}
>  

Calling 'free' before 'exit' seems like an exercise in
futility.. unless you want to remove warnings from 'valgrind' or
something like that...
How about I just remove the 'exit(0)', and it will fall through and
free(mount_point) and then exit (with a status that will be ignored)?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
