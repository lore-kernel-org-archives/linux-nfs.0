Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33447 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706Ab2JJM2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Oct 2012 08:28:36 -0400
Date: Wed, 10 Oct 2012 08:28:33 -0400
To: Ivan Romanov <drizt@land.ru>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: exportfs crash with long path
Message-ID: <20121010122833.GD2935@fieldses.org>
References: <1349708828.1183.5.camel@lix>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1349708828.1183.5.camel@lix>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 08, 2012 at 09:07:08PM +0600, Ivan Romanov wrote:
> Hello. I opened a bug with nfs-utils on Redhat Bugzilla. And got an
> advice to email upstream. So I just repeat my bug text with a patch.
> 
> How reproducible:
> always
> 
> Steps to Reproduce:
> # mkdir -p /home/kudinae/Общедоступные
> # echo '/home/kudinae/Общедоступные oek-1(rw,sync,no_wdelay,no_root_squash,no_subtree_check)' > /etc/exports
> # exportfs -a
> Segmentation fault
> 
> I've obtained the sources. So a crush happens on export.c:293. variable
> pos has negative value. I think problem into strtoint and export_hash
> functions. strtoint has unsigned type and always returns positive value
> but export_hash impicity cast it to signed int. So it is possible to
> get negative value. I wrote patch to fix this.

The fix looks right to me, thanks.--b.

> 
> Original Red Hat bug
> https://bugzilla.redhat.com/show_bug.cgi?id=863054

> diff --git a/support/export/export.c b/support/export/export.c
> index 4fda30a..0257903 100644
> --- a/support/export/export.c
> +++ b/support/export/export.c
> @@ -357,7 +357,7 @@ strtoint(char *str)
>  static int 
>  export_hash(char *str)
>  {
> -	int num = strtoint(str);
> +	unsigned int num = strtoint(str);
>  
>  	return num % HASH_TABLE_SIZE;
>  }

