From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 24/24] Removed warnings from configfile.c
Date: Wed, 21 Jul 2010 13:53:36 -0400
Message-ID: <4C473420.20802@oracle.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-25-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21475 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab0GURzC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 13:55:02 -0400
In-Reply-To: <1279669057-17509-25-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On 07/20/10 07:37 PM, Steve Dickson wrote:
> configfile.c:195: warning: 'inline' is not at beginning of declaration
> configfile.c:232: warning: 'inline' is not at beginning of declaration
>
> Signed-off-by: Steve Dickson<steved@redhat.com>
> ---
>   utils/mount/configfile.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> index 5cff009..3f3b249 100644
> --- a/utils/mount/configfile.c
> +++ b/utils/mount/configfile.c
> @@ -192,7 +192,7 @@ void free_all(void)
>   	}
>   }
>   static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
> -int inline check_vers(char *mopt, char *field)
> +inline int check_vers(char *mopt, char *field)

I don't see the purpose of using inline here, nor of keeping this a 
global function.  Is "inline" is addressing some Fortify warning?

If you're updating this, shouldn't it rather be:

static int
check_vers(char *mopt, char *field)

?

>   {
>   	int i, found=0;
>
> @@ -229,7 +229,7 @@ extern sa_family_t config_default_family;
>    * If so, set the appropriate global value which will
>    * be used as the initial value in the server negation.
>    */
> -int inline default_value(char *mopt)
> +inline int default_value(char *mopt)
>   {
>   	struct mount_options *options = NULL;
>   	int dftlen = strlen("default");

And likewise...?
