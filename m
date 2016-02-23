Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002AbcBWTlv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2016 14:41:51 -0500
Date: Tue, 23 Feb 2016 14:41:48 -0500
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc/cache: fix off-by-one in qword_get()
Message-ID: <20160223194148.GA1207@fieldses.org>
References: <1455821754-24940-1-git-send-email-stefanha@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1455821754-24940-1-git-send-email-stefanha@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 18, 2016 at 06:55:54PM +0000, Stefan Hajnoczi wrote:
> The qword_get() function NUL-terminates its output buffer.  If the input
> string is in hex format \xXXXX... and the same length as the output
> buffer, there is an off-by-one:

Thanks, I'll pass this along to Linus soon, for 4.5 and stable.

--b.

> 
>   int qword_get(char **bpp, char *dest, int bufsize)
>   {
>       ...
>       while (len < bufsize) {
>           ...
>           *dest++ = (h << 4) | l;
>           len++;
>       }
>       ...
>       *dest = '\0';
>       return len;
>   }
> 
> This patch ensures the NUL terminator doesn't fall outside the output
> buffer.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  net/sunrpc/cache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 2b32fd6..273bc3a 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1225,7 +1225,7 @@ int qword_get(char **bpp, char *dest, int bufsize)
>  	if (bp[0] == '\\' && bp[1] == 'x') {
>  		/* HEX STRING */
>  		bp += 2;
> -		while (len < bufsize) {
> +		while (len < bufsize - 1) {
>  			int h, l;
>  
>  			h = hex_to_bin(bp[0]);
> -- 
> 2.5.0
