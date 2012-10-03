Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54044 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2JCNeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2012 09:34:37 -0400
Received: by ieak13 with SMTP id k13so17147259iea.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2012 06:34:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349268173-16574-1-git-send-email-jlayton@redhat.com>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
	<1349268173-16574-1-git-send-email-jlayton@redhat.com>
Date: Wed, 3 Oct 2012 09:34:36 -0400
Message-ID: <CAFB9KM1xNQYJFS=hE=cFdTkZE9Da8qfhYRLSEJ2xVvwWzxJo1Q@mail.gmail.com>
Subject: Re: [PATCH 7/6] nfsdcltrack: add a legacy transition mechanism
From: Scott Lovenberg <scott.lovenberg@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 3, 2012 at 8:42 AM, Jeff Layton <jlayton@redhat.com> wrote:
[snip]
> +               /* if there's a problem, then skip this entry */
> +               if (len < 0 || (size_t)len >= sizeof(blob)) {
> +                       xlog(L_WARNING, "%s: unable to build filename for %s!",
> +                               __func__, entry->d_name);
> +                       continue;
> +               }

Is a len == 0 not a problem?

-- 
Peace and Blessings,
-Scott.
