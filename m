Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:58324 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388AbaJ2M3i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2014 08:29:38 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so2134548qgd.0
        for <linux-nfs@vger.kernel.org>; Wed, 29 Oct 2014 05:29:38 -0700 (PDT)
Date: Wed, 29 Oct 2014 08:29:34 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap.map: Add more global variables to the map.
Message-ID: <20141029082934.7875488c@tlielax.poochiereds.net>
In-Reply-To: <1414521607-8426-1-git-send-email-steved@redhat.com>
References: <1414521607-8426-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Oct 2014 14:40:07 -0400
Steve Dickson <steved@redhat.com> wrote:

> With the introduction of a symbol version map
> (commit 045d2e46d) all global variables need to
> be in the map for the plugins to load correctly
> 
> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1156484
> 
> Reported-by: Jeff Layton <jlayton@poochiereds.net>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  nfsidmap.map | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/nfsidmap.map b/nfsidmap.map
> index 540835c..1e7cf7e 100644
> --- a/nfsidmap.map
> +++ b/nfsidmap.map
> @@ -16,6 +16,10 @@ global:
>  	nfs4_gss_princ_to_ids_ex;
>  	nfs4_gss_princ_to_grouplist_ex;
>  	nfs4_set_debug;
> +	idmap_verbosity;
> +	idmap_log_func;
> +	get_default_domain;
> +	get_local_realms;
>  local:
>  	*;
>  };

Acked-by: Jeff Layton <jlayton@poochiereds.net>
