Return-Path: <SRS0=JLvH=7R=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B37B8C433DF
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Jun 2020 15:02:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 839BD207D8
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Jun 2020 15:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dDdpn18a"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729153AbgFDPCR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Jun 2020 11:02:17 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:29743 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1729139AbgFDPCQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2020 11:02:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1591282935;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=a1ED4QJKI/4Iqfn3JU6ZLGoyccqDWrmFfeRiynzHN94=;
        b=dDdpn18ajTN3AwlbpkOE8szf5lzzCD0g3q4N21eOn6nmCi35lOTo2u/DKru7EZJUA0wW59
        S80xTskEcYflMz9rkzO01Cf489NcfN4f1AdQElJJzycVqCxsoo1bFMeTQyyD+Cq17TZHyb
        qLAlNxDHB8w0tSBaelm/zldh2tkdE/U=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-196-dubSIxZSNROjZbcbgyW4HA-1; Thu, 04 Jun 2020 11:02:13 -0400
X-MC-Unique: dubSIxZSNROjZbcbgyW4HA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id C8094835B40
        for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2020 15:02:12 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-114-73.phx2.redhat.com [10.3.114.73])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 848A57CCCD;
        Thu,  4 Jun 2020 15:02:12 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] mountstats: add missing operations
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     linux-nfs@vger.kernel.org
References: <20200603182839.3282825-1-smayhew@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <e1681b95-3755-ac26-fa6d-f2cac580b5a5@RedHat.com>
Date:   Thu, 4 Jun 2020 11:02:12 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200603182839.3282825-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 6/3/20 2:28 PM, Scott Mayhew wrote:
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  tools/mountstats/mountstats.py | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
Committed... 

steved.

> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 3e2a3fe..f101ce5 100755
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -225,7 +225,12 @@ Nfsv4ops = [
>      'ALLOCATE',
>      'DEALLOCATE',
>      'LAYOUTSTATS',
> -    'CLONE'
> +    'CLONE',
> +    'COPY',
> +    'OFFLOAD_CANCEL',
> +    'LOOKUPP',
> +    'LAYOUTERROR',
> +    'COPY_NOTIFY'
>  ]
>  
>  def sec_conv(rem):
> 

