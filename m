Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:61019 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaIWUlO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 16:41:14 -0400
Received: by mail-vc0-f177.google.com with SMTP id im17so5842721vcb.36
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 13:41:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140923070733.25555.18292.stgit@unused-4-157.brq.redhat.com>
References: <20140923070733.25555.18292.stgit@unused-4-157.brq.redhat.com>
Date: Tue, 23 Sep 2014 16:41:13 -0400
Message-ID: <CAHQdGtRZA89spXkGWxoDyd8dRt-f9wfnfuz=rACsMe3bSa_meA@mail.gmail.com>
Subject: Re: [PATCH] mountd.man: mountd tcp wrappers support only NFS v2/v3
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jan Chaloupka <jchaloup@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 3:07 AM, Jan Chaloupka <jchaloup@redhat.com> wrote:
> mountd tcp wrappers support only NFSv2 and NFSv3, not NFSv4.
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1116283
>
> This patch updates the man page
>
> Signed-off-by: Jan Chaloupka <jchaloup@redhat.com>
> ---
>  utils/mountd/mountd.man |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
> index a8828ae..1aae75b 100644
> --- a/utils/mountd/mountd.man
> +++ b/utils/mountd/mountd.man
> @@ -217,6 +217,8 @@ listeners using the
>  .B tcp_wrapper
>  library or
>  .BR iptables (8).
> +Tcp wrappers are only in effect with NFS version 2 and 3 mounts.
> +They do not work with NFS version 4.
>  .PP
>  Note that the
>  .B tcp_wrapper
>

Is there any point to compiling mountd with the tcp wrappers in this
day and age? tcp wrappers isn't enforced by knfsd, so as the above
manpage change indicates it really is only blocking NFSv2/v3 _mount_
attempts.

If you can use NFSv4, or sniff the NFSv2/v3 traffic or even just guess
NFSv2/v3 filehandles, then tcp wrappers can be 100% circumvented.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
