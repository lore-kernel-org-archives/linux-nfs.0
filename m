Return-Path: <SRS0=77Hf=U7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78A3BC5B57D
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Jul 2019 06:31:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3CBF5216C8
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Jul 2019 06:31:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562049104;
	bh=82ee/JqwTflIBeAwu9pJlPEalam46uYT6iLFFaMkRDw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=rLc1Wiqh/XhkOvQqKEHmnyau3oD+PZULQX7bWwc+FgWMzCtgvn7aZnMm53SCP7W6J
	 wVbbej+v+fxl7s4pVtBt8A5liZZqnWW7Dwb5Njrtd7+XEkTRJK7Yq694TM4XfD9DxM
	 f3El0GTno4b1XRP66QBPgMNOd77vekHWyfOWkpDw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725835AbfGBGbn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Jul 2019 02:31:43 -0400
Received: from mail.kernel.org ([198.145.29.99]:54398 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725775AbfGBGbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Jul 2019 02:31:43 -0400
Received: from sol.localdomain (c-24-5-143-220.hsd1.ca.comcast.net [24.5.143.220])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 658CF20881;
        Tue,  2 Jul 2019 06:31:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1562049102;
        bh=82ee/JqwTflIBeAwu9pJlPEalam46uYT6iLFFaMkRDw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=SlEwihVh6ZclZbvkbDK36qIxxxrKoBvhLP7kaWBhN4PmW9yc6vI/LrX0s86y6PB7y
         +Z5T9PAoIO0Gq2zxseLKE1EA+YjMQT335cc6jXOLAVkeyrBeHXAhijpXBHBw9qH4dI
         R2kYh0P9ljaxqKkp0yc1txHFUR3HafjGtWR5BRMI=
Date:   Mon, 1 Jul 2019 23:31:40 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     syzbot <syzbot+7fe11b49c1cc30e3fce2@syzkaller.appspotmail.com>,
        anna.schumaker@netapp.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, syzkaller-bugs@googlegroups.com,
        trond.myklebust@hammerspace.com
Subject: Re: memory leak in nfs_get_client
Message-ID: <20190702063140.GE3054@sol.localdomain>
References: <000000000000f8a345058b046657@google.com>
 <223AB0C9-D93E-4D3C-BBBB-4AF40D8EA436@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <223AB0C9-D93E-4D3C-BBBB-4AF40D8EA436@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jun 11, 2019 at 12:23:12PM -0400, Benjamin Coddington wrote:
> Ugh.. Now that you can cancel the wait, you have to also handle if "new" was
> allocated.  I think this needs:
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index d7e4f0848e28..4d90f5bf0b0a 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -406,10 +406,10 @@ struct nfs_client *nfs_get_client(const struct
> nfs_client_initdata *cl_init)
>                 clp = nfs_match_client(cl_init);
>                 if (clp) {
>                         spin_unlock(&nn->nfs_client_lock);
> -                       if (IS_ERR(clp))
> -                               return clp;
>                         if (new)
>                                 new->rpc_ops->free_client(new);
> +                       if (IS_ERR(clp))
> +                               return clp;
>                         return nfs_found_client(cl_init, clp);
>                 }
>                 if (new) {
> 
> I'll patch/test and send it along.
> 
> Ben

Hi Ben, what happened to this patch?

- Eric
