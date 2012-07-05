Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755772Ab2GETj4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 15:39:56 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q65JdtQ7027061
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jul 2012 15:39:56 -0400
Message-ID: <4FF5ED44.2000702@RedHat.com>
Date: Thu, 05 Jul 2012 15:38:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap: Default domain not being set.
References: <1341493903-20835-1-git-send-email-steved@redhat.com>
In-Reply-To: <1341493903-20835-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/05/2012 09:11 AM, Steve Dickson wrote:
> nfsidmap is not calling the nfs4_init_name_mapping()
> function which initializes the default domain from
> either the DNS domain or the Domain variable in /etc/idmap.conf
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  utils/nfsidmap/nfsidmap.c |   20 +++++++-------------
>  1 file changed, 7 insertions(+), 13 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index b767395..e14543c 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -37,17 +37,6 @@ static int keyring_clear(char *keyring);
>  #define GIDKEYS 0x2
>  
>  /*
> - * Check to the config file for the verbosity level
> - */
> -int
> -get_config_verbose(char *path)
> -{
> -	conf_path = path;
> -	conf_init();
> -	return conf_get_num("General", "Verbosity", 0);
> -}
> -
> -/*
>   * Find either a user or group id based on the name@domain string
>   */
>  int id_lookup(char *name_at_domain, key_serial_t key, int type)
> @@ -282,9 +271,14 @@ int main(int argc, char **argv)
>  			break;
>  		}
>  	}
> -	if (!verbose) {
> -		verbose = get_config_verbose(PATH_IDMAPDCONF);
> +
> +	if (nfs4_init_name_mapping(PATH_IDMAPDCONF))  {
> +		xlog_err("Unable to create name to user id mappings.");
> +		return 1;
>  	}
> +	if (!verbose)
> +		verbose = conf_get_num("General", "Verbosity", 0);
> +
>  	if (keystr) {
>  		rc = key_revoke(keystr, keymask);
>  		return rc;		
