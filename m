Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755249AbdKNRvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Nov 2017 12:51:31 -0500
Subject: Re: [Libtirpc-devel] [PATCH] libtirpc.map: fix misspelled symbol
 key_secretkey_is_set
To: Felix Janda <felix.janda@posteo.de>,
        libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
References: <20171111185454.GA30165@nyan>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <0a65666d-1035-960c-d0eb-cb962633b9b8@RedHat.com>
Date: Tue, 14 Nov 2017 12:51:30 -0500
MIME-Version: 1.0
In-Reply-To: <20171111185454.GA30165@nyan>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/2017 01:54 PM, Felix Janda wrote:
> Signed-off-by: Felix Janda <felix.janda@posteo.de>
> ---
>  src/libtirpc.map | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/src/libtirpc.map b/src/libtirpc.map
> index f385de5..21d6065 100644
> --- a/src/libtirpc.map
> +++ b/src/libtirpc.map
> @@ -298,7 +298,7 @@ TIRPC_0.3.2 {
>      key_gendes;
>      key_get_conv;
>      key_setsecret;
> -    key_secret_is_set;
> +    key_secretkey_is_set;
>      key_setnet;
>      netname2host;
>      netname2user;
> 
This was committed via another patch set...

steved.
