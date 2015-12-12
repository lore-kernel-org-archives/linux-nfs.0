Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbbLLMNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:13:45 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 5D79542E5DA
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 12:13:45 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v2] statd: make statd_canonical_name return the
 presentation address if it maps to an empty hostname
To: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
References: <1449512542-19826-1-git-send-email-smayhew@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0F78.4070006@RedHat.com>
Date: Sat, 12 Dec 2015 07:13:44 -0500
MIME-Version: 1.0
In-Reply-To: <1449512542-19826-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/07/2015 01:22 PM, Scott Mayhew wrote:
> Certain name resolution misconfigurations (for example, a hosts file
> entry with an ip address but no hostnames) can cause get_nameinfo() to
> return an empty string in buf, which will lead to this cryptic failure:
> 
> Dec  7 09:37:44 hostname rpc.statd[8024]: Failed to insert: creating
> /var/lib/nfs/statd/sm/: Is a directory
> Dec  7 09:37:44 hostname rpc.statd[8024]: STAT_FAIL to
> hostname.example.com for SM_MON of 192.168.1.2
> Dec  7 09:37:44 hostname kernel: lockd: cannot monitor 192.168.1.2
> 
> It's better in that case to just go ahead and use the presentation
> address instead.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  utils/statd/hostname.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
> index c61087c..8cccdb8 100644
> --- a/utils/statd/hostname.c
> +++ b/utils/statd/hostname.c
> @@ -180,9 +180,6 @@ get_nameinfo(const struct sockaddr *sap,
>   * Incoming hostnames are looked up to determine the canonical hostname,
>   * and incoming presentation addresses are converted to canonical
>   * hostnames.
> - *
> - * We won't monitor peers that don't have a reverse map.  The canonical
> - * name gives us a key for our monitor list.
>   */
>  __attribute__((__malloc__))
>  char *
> @@ -207,7 +204,7 @@ statd_canonical_name(const char *hostname)
>  		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
>  					buf, (socklen_t)sizeof(buf));
>  		freeaddrinfo(ai);
> -		if (!result)
> +		if (!result || buf[0] == '\0')
>  			/* OK to use presentation address,
>  			 * if no reverse map exists */
>  			return strdup(hostname);
> 
