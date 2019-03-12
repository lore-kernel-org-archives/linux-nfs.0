Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C76DC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 13:17:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55ACB214D8
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 13:17:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726304AbfCLNR5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 09:17:57 -0400
Received: from mx1.redhat.com ([209.132.183.28]:37726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726009AbfCLNR5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 09:17:57 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0DA9F3099FC3
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 13:17:57 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id CEC7A5C280
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 13:17:56 +0000 (UTC)
Subject: Re: [PATCH] gssd: add verbosity options to the rpc.gssd man page
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20190311175521.24526-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <ea315433-eace-af27-2dcc-e2689ed7640c@RedHat.com>
Date:   Tue, 12 Mar 2019 09:17:55 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311175521.24526-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 12 Mar 2019 13:17:57 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/11/19 1:55 PM, Steve Dickson wrote:
> From: Pierguido Lambri <plambri@redhat.com>
> 
> It also adds the commented out entries in the nfs.conf
> default file.
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1668026
> 
> Signed-off-by: Pierguido Lambri <plambri@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  nfs.conf             | 2 ++
>  systemd/nfs.conf.man | 2 ++
>  utils/gssd/gssd.c    | 4 ++--
>  3 files changed, 6 insertions(+), 2 deletions(-)
Committed...

steved.
> 
> diff --git a/nfs.conf b/nfs.conf
> index d332375..faa07b1 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -9,6 +9,8 @@
>  # debug=0
>  #
>  [gssd]
> +# verbosity=0
> +# rpc-verbosity=0
>  # use-memcache=0
>  # use-machine-creds=1
>  # use-gss-proxy=0
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index 699db3f..e3654a3 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -211,6 +211,8 @@ for details.
>  .TP
>  .B gssd
>  Recognized values:
> +.BR verbosity ,
> +.BR rpc-verbosity ,
>  .BR use-memcache ,
>  .BR use-machine-creds ,
>  .BR use-gss-proxy ,
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 7eeb05f..19ad4da 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -890,8 +890,8 @@ main(int argc, char *argv[])
>  
>  	read_gss_conf();
>  
> -	verbosity = conf_get_num("gssd", "Verbosity", verbosity);
> -	rpc_verbosity = conf_get_num("gssd", "RPC-Verbosity", rpc_verbosity);
> +	verbosity = conf_get_num("gssd", "verbosity", verbosity);
> +	rpc_verbosity = conf_get_num("gssd", "rpc-verbosity", rpc_verbosity);
>  
>  	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
>  		switch (opt) {
> 
