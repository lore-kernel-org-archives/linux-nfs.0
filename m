From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Thu, 4 Sep 2008 17:36:17 -0400
Message-ID: <76bd70e30809041436y4a8fc1d2hb8230cb7aba17f26@mail.gmail.com>
References: <20080903203414.3322.97607.stgit@tarkus.1015granger.net>
	 <20080904202302.GD13981@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:7527 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbYIDVgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 17:36:19 -0400
Received: by nf-out-0910.google.com with SMTP id d3so63753nfc.21
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 14:36:17 -0700 (PDT)
In-Reply-To: <20080904202302.GD13981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 4, 2008 at 4:23 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Sep 03, 2008 at 04:35:57PM -0400, Chuck Lever wrote:
>> Bruce observed that nfs_parse_ip_address() will successfully parse an
>> IPv6 address that looks like this:
>>
>>   "::1%"
>>
>> A scope delimiter is present, but there is no scope ID following it.
>> This is harmless, as it would simply set the scope ID to zero.  However,
>> in some cases we would like to flag this as an improperly formed
>> address.
>>
>> We are now also careful to reject addresses where garbage follows the
>> address (up to the length of the string), instead of ignoring the
>> non-address characters; and where the scope ID is nonsense (not a valid
>> device name, but also not numeric).  Before, both of these cases would
>> result in a harmless zero scope ID.
>
> Slightly irrelevant, but same comment as before--wouldn't it be easier
> to follow the logic if instead of:
>
>        p = kstrndup(...)
>        if (p) {
>                do stuff for successful case
>                ....
>                return 1;
>        }
>
>        return 0;
>
> it were:
>
>        p = kstrndup(...)
>        if (!p)
>                return 0;
>        do stuff for successful case
>        ...
>        return 1;

I tried that.  It made this patch about 3x larger than it needed to
be, obscured the changes introduced by the patch, and made it harder
to show that the new logic is correct.  As we are not introducing new
code here but repairing existing issues, such a clean up would need to
be in a separate patch.

I generally prefer to use a structured language as it was intended,
rather than to abuse "goto" as is the trend in the Linux kernel.  By
creating named subroutines instead of using lambda functions and using
brackets creatively and intelligently, we codify the assumptions and
architecture of a set of tasks without excessive comments.  This also
limits the scope of automatic variables and keeps each function nearly
as simple as possible, making the code more robust in the face of
changes over time by multiple forgetful developers.

In addition, using positive instead of negative logic groups the
"success" path together into a few lines rather than spreading it out
over the whole function.  Writing this way is a style preference;
Knuth (?) and others make an argument in favor of it.  Often this is a
good way to ensure error handling is correct (eg memory allocations
are guaranteed to be properly freed in every error case because the
structuring forces it).

C suffers from a lack of proper exception handling constructs, which
would help readability and correct error case handling.  But these
functions are small enough that writing them using structured precepts
is simple enough and doesn't have a strong negative effect on
readability.

Also, the C compiler assumes the "if" expression will evaluate to TRUE
more often than FALSE so it arranges the branch instructions so that
the CPU's branch prediction logic will work more efficiently.  Not
really critical in this particular case.

Finally when practical I try to use a single exit/return point to
reduce code duplication and to arrange the code in advance for easier
debugging, though sometimes that obfuscates.

Though I am not always consistent on these points, I don't see a
strong need to re-arrange as you suggest in this case.

>
> e.g., the below, on top of yours. (Untested.)
>
> Might also combine the two final exits in the usual way:
>
>        out:
>                kfree(p);
>                return ret;
>
> --b.
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a9f5a12..fcee897 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -733,6 +733,8 @@ static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
>  {
>        size_t len = (string + str_len) - delim - 1;
>        char *p;
> +       unsigned long scope_id = 0;
> +       struct net_device *dev;
>
>        if (len == 0)
>                return 1;
> @@ -744,29 +746,25 @@ static int nfs_parse_ipv6_scope_id(const char *string, const size_t str_len,
>                return 0;
>
>        p = kstrndup(delim + 1, len, GFP_KERNEL);
> -       if (p) {
> -               unsigned long scope_id = 0;
> -               struct net_device *dev;
> -
> -               dev = dev_get_by_name(&init_net, p);
> -               if (dev != NULL) {
> -                       scope_id = dev->ifindex;
> -                       dev_put(dev);
> -               } else {
> -                       if (strict_strtoul(p, 10, &scope_id) == 0) {
> -                               kfree(p);
> -                               return 0;
> -                       }
> -               }
> -
> -               kfree(p);
> +       if (!p)
> +               return 0;
>
> -               sin6->sin6_scope_id = scope_id;
> -               dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
> -               return 1;
> +       dev = dev_get_by_name(&init_net, p);
> +       if (dev != NULL) {
> +               scope_id = dev->ifindex;
> +               dev_put(dev);
> +       } else {
> +               if (strict_strtoul(p, 10, &scope_id) == 0) {
> +                       kfree(p);
> +                       return 0;
> +               }
>        }
>
> -       return 0;
> +       kfree(p);
> +
> +       sin6->sin6_scope_id = scope_id;
> +       dfprintk(MOUNT, "NFS: IPv6 scope ID = %lu\n", scope_id);
> +       return 1;
>  }
>
>  static void nfs_parse_ipv6_address(char *string, size_t str_len,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
"If you simplify your English, you are freed from the worst follies of
orthodoxy."
 -- George Orwell
