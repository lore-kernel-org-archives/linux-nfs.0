Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC75DC77B77
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Apr 2023 14:38:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230268AbjDMOiZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 13 Apr 2023 10:38:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34058 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229994AbjDMOiZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Apr 2023 10:38:25 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4718B974C
        for <linux-nfs@vger.kernel.org>; Thu, 13 Apr 2023 07:37:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1681396658;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=zh48LH+lWIDcMUTRVYARFiiBOHlN0g/yHS2D9XaBS5s=;
        b=YM+OCvdk3AfDkgKu4sxGgOjduiSyPbKFbEMBiqy9qIfgthyWPU32HTMMlLORnTZnIsoOVs
        BtonLn/HqxgQvsuBrKkcuJlwuIXP5kwEslT5UR4/QCAPodg4WPQAK4rrvwILqMF0NtW+um
        T1CvCmuOQj/xbdaYpvrZqeRyDhDzA6c=
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-345-L-s4HvYwN1Oj_kK05l1ztg-1; Thu, 13 Apr 2023 10:37:35 -0400
X-MC-Unique: L-s4HvYwN1Oj_kK05l1ztg-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 93EDB1C17423;
        Thu, 13 Apr 2023 14:37:34 +0000 (UTC)
Received: from aion.usersys.redhat.com (unknown [10.22.32.87])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 8357E1121330;
        Thu, 13 Apr 2023 14:37:34 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id 1C6971A27F5; Thu, 13 Apr 2023 10:37:34 -0400 (EDT)
Date:   Thu, 13 Apr 2023 10:37:34 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     David Howells <dhowells@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        linux-nfs@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: Fix RFC6803 encryption test
Message-ID: <ZDgTrsTIsYvF78nP@aion.usersys.redhat.com>
References: <1078410.1681393916@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1078410.1681393916@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.3
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 13 Apr 2023, David Howells wrote:

>     
> The usage_data[] array in rfc6803_encrypt_case() is uninitialised, so clear
> it as it may cause the tests to fail otherwise.
> 
> Fixes: b958cff6b27b ("SUNRPC: Add encryption KUnit tests for the RFC 6803 encryption types")
> Link: https://lore.kernel.org/r/380323.1681314997@warthog.procyon.org.uk/
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Chuck Lever <chuck.lever@oracle.com>
> cc: Scott Mayhew <smayhew@redhat.com>
> cc: Herbert Xu <herbert@gondor.apana.org.au>
> cc: linux-nfs@vger.kernel.org
> cc: linux-crypto@vger.kernel.org
> ---
>  net/sunrpc/auth_gss/gss_krb5_test.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_test.c b/net/sunrpc/auth_gss/gss_krb5_test.c
> index ce0541e32fc9..aa6ec4e858aa 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_test.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_test.c
> @@ -1327,6 +1327,7 @@ static void rfc6803_encrypt_case(struct kunit *test)
>  	if (!gk5e)
>  		kunit_skip(test, "Encryption type is not available");
>  
> +	memset(usage_data, 0, sizeof(usage_data));
>  	usage.data[3] = param->constant;
>  
>  	Ke.len = gk5e->Ke_length;
> 

I still see the failures with this patch applied.  The rfc6803 checksum
tests run before the rfc6803 encryption tests, so I'm not sure how this
would help.

-Scott

