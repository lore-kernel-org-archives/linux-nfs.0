Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51119 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab1JaVQn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 17:16:43 -0400
Received: by wwf22 with SMTP id 22so2389379wwf.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 14:16:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E9E1F3A.2090709@tonian.com>
References: <4E9E1F3A.2090709@tonian.com>
Date: Mon, 31 Oct 2011 17:16:41 -0400
Message-ID: <CAN-5tyEF9j92qhPPPw9__B78Km1rUXC+wEOD642Wxts=N4ZOsg@mail.gmail.com>
Subject: Re: [PATCH] pnfsd: dlm: fix bug in DS tcp/tcp6 address string
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Michael Groshans <groshans@umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny, this patch does not fix the issue. Except that now all the
entries list "tcp6". Previously if you recall first data server entry
was correct but others listed tcp6 type with it was suppose to be tcp.

On Tue, Oct 18, 2011 at 8:52 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> squash into "pnfsd: Correctly set netid to tcp or tcp6 for non-local exports"
>
> Currently, the code looks for ':' using strcspn that requires a null terminated string
> while the address buffer isn't null terminated.
>
> Instead, just use strnchr to look for a ':' and if not found assume
> it's an IPv4 address, otherwise it's IPv6
>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4pnfsdlm.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index abc4d83..d07a6037 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -328,13 +328,8 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
>                memcpy(daddr->r_addr.data + len, ".8.1", 4);
>                daddr->r_addr.len = len + 4;
>
> -               if (strcspn(daddr->r_addr.data, ":") - 1 == daddr->r_addr.len) {
> -                       daddr->r_netid.data = "tcp";
> -                       daddr->r_netid.len = 3;
> -               } else {
> -                       daddr->r_netid.data = "tcp6";
> -                       daddr->r_netid.len = 4;
> -               }
> +               daddr->r_netid.data = "tcp6";
> +               daddr->r_netid.len = strnchr(daddr->r_addr.data, len, ':') ? 4 : 3;
>
>                fdev.fl_device_list[i].fl_multipath_length = 1;
>                fdev.fl_device_list[i].fl_multipath_list = daddr;
> --
> 1.7.6
>
>
