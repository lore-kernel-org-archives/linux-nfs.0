From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] Fix mountd memory leak in nfsd_fh
Date: Mon, 27 Aug 2007 14:11:20 -0400
Message-ID: <20070827181120.GG3118@fieldses.org>
References: <200708271521.l7RFLZJN019407@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPj3c-0007lt-NL
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 11:11:24 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPj3c-0006v8-Tr
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 11:11:26 -0700
In-Reply-To: <200708271521.l7RFLZJN019407@dantu.rdu.redhat.com>
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

On Mon, Aug 27, 2007 at 11:21:35AM -0400, Jeff Layton wrote:
> nfsd_fh() uses strdup for creating found_path and doesn't check the
> return value. It also doesn't free this memory when the function
> returns. Change it to use xstrdup, and free found_path on exit.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Acked-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/cache.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 15100d4..77fee01 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -444,7 +444,7 @@ void nfsd_fh(FILE *f)
>  			/* It's a match !! */
>  			if (!found) {
>  				found = &exp->m_export;
> -				found_path = strdup(path);
> +				found_path = xstrdup(path);

For a long-running daemon like mountd, wouldn't it be better to drop the
request or return an error instead of dying on malloc() failure?  Or is
it hopeless at that point anyway?  (Not an objection to this patch since
the code does this elsewhere already--I'm just curious.)

> @@ -492,6 +492,8 @@ void nfsd_fh(FILE *f)
>  		qword_print(f, found->e_path);
>  	qword_eol(f);
>   out:
> +	if (found_path)
> +		free(found_path);

The "if" is unnecessary.

>  	free(dom);
>  	return;		
>  }

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
