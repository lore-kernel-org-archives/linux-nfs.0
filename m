Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36066 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751721AbdFFOhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 10:37:11 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A845715561
        for <linux-nfs@vger.kernel.org>; Tue,  6 Jun 2017 14:37:05 +0000 (UTC)
Subject: Re: [PATCH 2/3] nfs.conf tidy ups
To: Justin Mitchell <jumitche@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <1495468204.4169.10.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d430e93a-3d63-4985-8d92-1a444629f041@RedHat.com>
Date: Tue, 6 Jun 2017 10:37:04 -0400
MIME-Version: 1.0
In-Reply-To: <1495468204.4169.10.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/22/2017 11:50 AM, Justin Mitchell wrote:
> Add function to cleanup and free the loaded config
> 
> Signed-off-by: Justin Mitchell <jumitche@rehat.com>
Committed... 

steved.

> 
> ---
>  support/include/conffile.h |  1 +
>  support/nfs/conffile.c     | 51 +++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 45 insertions(+), 7 deletions(-)
> 
> diff --git a/support/include/conffile.h b/support/include/conffile.h
> index 20b1a32..2d11a52 100644
> --- a/support/include/conffile.h
> +++ b/support/include/conffile.h
> @@ -60,6 +60,7 @@ extern _Bool    conf_get_bool(char *, char *, _Bool);
>  extern char    *conf_get_str(char *, char *);
>  extern char    *conf_get_section(char *, char *, char *);
>  extern void     conf_init(const char *);
> +extern void     conf_cleanup(void);
>  extern int      conf_match_num(char *, char *, int);
>  extern int      conf_remove(int, char *, char *);
>  extern int      conf_remove_section(int, char *);
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index a76c7e3..7c607c0 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -414,13 +414,32 @@ conf_load(int trans, const char *path)
>  	return -1;
>  }
>  
> +/* remove and free up any existing config state */
> +static void conf_free_bindings(void)
> +{
> +	unsigned int i;
> +	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
> +		struct conf_binding *cb, *next;
> +
> +		cb = LIST_FIRST(&conf_bindings[i]);
> +		for (; cb; cb = next) {
> +			next = LIST_NEXT(cb, link);
> +			LIST_REMOVE(cb, link);
> +			free(cb->section);
> +			free(cb->arg);
> +			free(cb->tag);
> +			free(cb->value);
> +			free(cb);
> +		}
> +		LIST_INIT(&conf_bindings[i]);
> +	}
> +}
> +
>  /* Open the config file and map it into our address space, then parse it.  */
>  static void
>  conf_reinit(const char *conf_file)
>  {
> -	struct conf_binding *cb = 0;
>  	int trans;
> -	unsigned int i;
>  
>  	trans = conf_begin();
>  	if (conf_load(trans, conf_file) < 0)
> @@ -430,12 +449,9 @@ conf_reinit(const char *conf_file)
>  	conf_load_defaults();
>  
>  	/* Free potential existing configuration.  */
> -	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++) {
> -		cb = LIST_FIRST (&conf_bindings[i]);
> -		for (; cb; cb = LIST_FIRST (&conf_bindings[i]))
> -			conf_remove_now(cb->section, cb->tag);
> -	}
> +	conf_free_bindings();
>  
> +	/* Apply the new configuration values */
>  	conf_end(trans, 1);
>  	return;
>  }
> @@ -454,6 +470,27 @@ conf_init (const char *conf_file)
>  	conf_reinit(conf_file);
>  }
>  
> +/* 
> + * Empty the config and free up any used memory 
> + */
> +void
> +conf_cleanup(void)
> +{
> +	conf_free_bindings();
> +
> +	struct conf_trans *node, *next;
> +	for (node = TAILQ_FIRST(&conf_trans_queue); node; node = next) {
> +		next = TAILQ_NEXT(node, link);
> +		TAILQ_REMOVE (&conf_trans_queue, node, link);
> +		if (node->section) free(node->section);
> +		if (node->arg) free(node->arg);
> +		if (node->tag) free(node->tag);
> +		if (node->value) free(node->value);
> +		free (node);
> +	}
> +	TAILQ_INIT(&conf_trans_queue);
> +}
> +
>  /*
>   * Return the numeric value denoted by TAG in section SECTION or DEF
>   * if that tag does not exist.
> 
