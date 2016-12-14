Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37082 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755859AbcLNOdX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Dec 2016 09:33:23 -0500
Date: Wed, 14 Dec 2016 09:33:22 -0500
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] conffile: fix striping of quotes from values.
Message-ID: <20161214143322.GB30113@fieldses.org>
References: <148117122602.31271.13586847542442809540.stgit@noble>
 <148117124536.31271.10187990246409032535.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <148117124536.31271.10187990246409032535.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 03:27:25PM +1100, NeilBrown wrote:
> There were being stripes from the name instead!

s/stripes/stripped/.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  support/nfs/conffile.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 57f58a2bcdc7..e717c1e39bab 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -300,14 +300,14 @@ conf_parse_line(int trans, char *line, size_t sz)
>  			line[strcspn (line, " \t=")] = '\0';
>  			val = line + i + 1 + strspn (line + i + 1, " \t");
>  
> -			if (line[0] == '"') {
> -				line ++;
> -				j = strcspn(line, "\"");
> -				line[j] = 0;
> -			} else if (line[0] == '\'') {
> -				line ++;
> -				j = strcspn(line, "'");
> -				line[j] = 0;
> +			if (val[0] == '"') {
> +				val ++;
> +				j = strcspn(val, "\"");
> +				val[j] = 0;
> +			} else if (val[0] == '\'') {
> +				val ++;
> +				j = strcspn(val, "'");
> +				val[j] = 0;
>  			} else {
>  				/* Skip trailing spaces and comments */
>  				for (j = 0; val[j]; j++) {
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
