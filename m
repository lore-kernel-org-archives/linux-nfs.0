Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:42825 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751577AbeERSxl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 14:53:41 -0400
Received: by mail-vk0-f67.google.com with SMTP id j7-v6so5427128vkc.9
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 11:53:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 18 May 2018 14:53:39 -0400
Message-ID: <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Simo Sorce <simo@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

I'm not convinced that "srchost=" is necessary. I believe that
everything that is needed is suppose to be encoded in the "target="
option.

I thought target just needed to correctly identify the domain for
which authentication is taking place. Then I think more changes should
be in nfs-utils to make sure that we find credentials for that
particular domain instead of going by the gethostbyname() results.


On Fri, May 18, 2018 at 11:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> I've been experimenting with this series that modifies NFSD to
> discover and use the correct GSS service principal when constructing
> its NFSv4.0 callback channels. I'm interested in review of this
> approach. There are a couple of code comments marked with XXX that
> also need some attention.
>
> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
> made available once there is consensus about the kernel changes
> in this series. No gssproxy changes are necessary.
>
> ---
>
> Chuck Lever (4):
>       sunrpc: Enable the kernel to specify the hostname part of service principals
>       sunrpc: Extract target name into svc_cred
>       nfsd: Use correct credential for NFSv4.0 callback with GSS
>       nfsd: Remove callback_cred
>
>
>  fs/nfsd/nfs4callback.c               |   29 ++++----------
>  fs/nfsd/nfs4state.c                  |   17 +++-----
>  fs/nfsd/state.h                      |    2 -
>  include/linux/sunrpc/svcauth.h       |    3 +
>  net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
>  6 files changed, 80 insertions(+), 61 deletions(-)
>
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
