Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766AbaIKPx0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:53:26 -0400
Date: Thu, 11 Sep 2014 11:53:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/7] nfsdcltrack: update comments in sqlite.c
Message-ID: <20140911155324.GB16635@fieldses.org>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
 <1410193821-25109-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410193821-25109-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 08, 2014 at 12:30:16PM -0400, Jeff Layton wrote:
> Clean up and fix some inaccuracies.

By the way, I also notice the man page refers to it as a daemon.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  utils/nfsdcltrack/sqlite.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
> index bac678980938..352f029d55c0 100644
> --- a/utils/nfsdcltrack/sqlite.c
> +++ b/utils/nfsdcltrack/sqlite.c
> @@ -21,17 +21,15 @@
>   * Explanation:
>   *
>   * This file contains the code to manage the sqlite backend database for the
> - * clstated upcall daemon.
> + * nfsdcltrack usermodehelper upcall program.
>   *
>   * The main database is called main.sqlite and contains the following tables:
>   *
>   * parameters: simple key/value pairs for storing database info
>   *
> - * clients: one column containing a BLOB with the as sent by the client
> - * 	    and a timestamp (in epoch seconds) of when the record was
> - * 	    established
> - *
> - * FIXME: should we also record the fsid being accessed?
> + * clients: an "id" column containing a BLOB with the long-form clientid as
> + * 	    sent by the client, a "time" column containing a timestamp (in
> + * 	    epoch seconds) of when the record was last updated.
>   */
>  
>  #ifdef HAVE_CONFIG_H
> -- 
> 1.9.3
> 
