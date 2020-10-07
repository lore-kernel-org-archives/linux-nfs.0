Return-Path: <SRS0=1cAr=DO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45EE9C4363C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 21:25:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A19D320872
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 21:25:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="aZKkDgNC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728172AbgJGVZB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Oct 2020 17:25:01 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40000 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727798AbgJGVZB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2020 17:25:01 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EACA0C061755
        for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2020 14:25:00 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 05FA569C3; Wed,  7 Oct 2020 17:25:00 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 05FA569C3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1602105900;
        bh=GMBTVl4PWqRFyeyu/0FnGKpJkOooQD/TNilDbG9X3Ok=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=aZKkDgNC/Runr/foY5VwXc0ouTDBAL620aJhMSBjOhTmZKDwMk19MIath80JqdktF
         gncLRXjNAteaiRHeA8sw9fv5Uicajf9BwD8b5//EaO0K7diWlEkgFkSiX8wdzQbuRK
         tRqTqLKhczxz3Sl7G+kelNavSSYXSEEmjKhbuWyQ=
Date:   Wed, 7 Oct 2020 17:25:00 -0400
To:     trondmy@kernel.org
Cc:     Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSv4: Use the net namespace uniquifier if it is set
Message-ID: <20201007212500.GI23452@fieldses.org>
References: <20201007210720.537880-1-trondmy@kernel.org>
 <20201007210720.537880-2-trondmy@kernel.org>
 <20201007210720.537880-3-trondmy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201007210720.537880-3-trondmy@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 07, 2020 at 05:07:20PM -0400, trondmy@kernel.org wrote:
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> 
> If a container sets a net namespace specific uniquifier,

What you're actually checking is if nn->nfs_client != NULL, and that's
pretty much always true.  (The only time it's NULL is an allocation
failure in some initialization code, I think.)

> +	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
> +	struct nfs_netns_client *nn_clp = nn->nfs_client;
> +	const char *id;
> +	size_t len;
> +
>  	buf[0] = '\0';
> +
> +	if (nn_clp) {

Are you sure you don't mean

	if (nn_clp->identifier)

?

I think that's how you tell if someone's set it.

--b.

> +		rcu_read_lock();
> +		id = rcu_dereference(nn_clp->identifier);
> +		if (id && *id != '\0')
> +			len = strlcpy(buf, id, buflen);
> +		rcu_read_unlock();
> +		if (len)
> +			return len;
> +	}
> +
>  	if (nfs4_client_id_uniquifier[0] != '\0')
>  		return strlcpy(buf, nfs4_client_id_uniquifier, buflen);
>  	return 0;
> @@ -6034,7 +6051,7 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp)
>  		1;
>  	rcu_read_unlock();
>  
> -	buflen = nfs4_get_uniquifier(buf, sizeof(buf));
> +	buflen = nfs4_get_uniquifier(clp, buf, sizeof(buf));
>  	if (buflen)
>  		len += buflen + 1;
>  
> @@ -6081,7 +6098,7 @@ nfs4_init_uniform_client_string(struct nfs_client *clp)
>  	len = 10 + 10 + 1 + 10 + 1 +
>  		strlen(clp->cl_rpcclient->cl_nodename) + 1;
>  
> -	buflen = nfs4_get_uniquifier(buf, sizeof(buf));
> +	buflen = nfs4_get_uniquifier(clp, buf, sizeof(buf));
>  	if (buflen)
>  		len += buflen + 1;
>  
> -- 
> 2.26.2
