From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/14] NLM: Remove "create" argument from nsm_find()
Date: Wed, 29 Oct 2008 16:48:17 -0400
Message-ID: <20081029204817.GD1406@fieldses.org>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net> <20081024181123.23810.65076.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52145 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbYJ2UsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 16:48:19 -0400
In-Reply-To: <20081024181123.23810.65076.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2008 at 02:11:23PM -0400, Chuck Lever wrote:
> Clean up: nsm_find() now has only one caller who always sets the

Clearer to say: "now only has one caller, and that caller always
sets...".

> "create" argument, so it is no longer needed.  Since nsm_find() now
> has a more specific function, pick a more appropriate name for it.
...
> -struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
> -			    const char *hostname, const size_t hostname_len,
> -			    const int create)
> +struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
> +				  const size_t salen, const char *hostname,
> +				  const size_t hostname_len)
>  {

Maybe "nsm_create_handle" would be even clearer?  (It doesn't just
increment a reference counter.)

--b.
