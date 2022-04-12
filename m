Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51BEDC433F5
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Apr 2022 23:38:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230439AbiDLXlJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Apr 2022 19:41:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59762 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230422AbiDLXkz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2022 19:40:55 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 55EBA92850;
        Tue, 12 Apr 2022 16:22:24 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E1D3B61253;
        Tue, 12 Apr 2022 23:22:23 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9ADCAC385A1;
        Tue, 12 Apr 2022 23:22:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
        s=korg; t=1649805743;
        bh=LhsrzMk77NQcPYdzCX5hauu5G7NVYwkJ4kIRPOYv+jk=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=OUPqbvxsOygFrdjKnucWtXRA6pZ58t4BbVh6aJItY6VIkO0ECkmgTLNww9ch3/54L
         /cgUn+gNN3s6PE28IRe52XAJ1cKjhDDVt6/4sGzmDIbG5elo2++1OewvsV5XqSxRYr
         Wea5kCBi12XMe7idooeG7FBpQy+8iPUMmt4Xga7M=
Date:   Tue, 12 Apr 2022 16:22:21 -0700
From:   Andrew Morton <akpm@linux-foundation.org>
To:     Hugh Dickins <hughd@google.com>
Cc:     Christoph Hellwig <hch@lst.de>,
        Chuck Lever III <chuck.lever@oracle.com>,
        Mark Hemment <markhemm@googlemail.com>,
        Patrice CHOTARD <patrice.chotard@foss.st.com>,
        Mikulas Patocka <mpatocka@redhat.com>,
        Lukas Czerner <lczerner@redhat.com>,
        "Darrick J. Wong" <djwong@kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-stm32@st-md-mailman.stormreply.com, viro@zeniv.linux.org.uk
Subject: Re: [PATCH] tmpfs: fix regressions from wider use of ZERO_PAGE
Message-Id: <20220412162221.7c55379548017bab61ea5103@linux-foundation.org>
In-Reply-To: <f73cfd56-35d2-53a3-3a59-4ff9495d7d34@google.com>
References: <9a978571-8648-e830-5735-1f4748ce2e30@google.com>
        <20220409050638.GB17755@lst.de>
        <f73cfd56-35d2-53a3-3a59-4ff9495d7d34@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 8 Apr 2022 23:08:29 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> > 
> > Either way I'd rather do this optimization in iov_iter_zero rather
> > than hiding it in tmpfs.
> 
> Let's see what others say.  I think we would all prefer clear_user() to be
> enhanced, and hack around it neither here in tmpfs nor in iov_iter_zero().
> But that careful work won't get done by magic, nor by me.
> 
> And iov_iter_zero() has to deal with a wider range of possibilities,
> when pulling in cache lines of ZERO_PAGE(0) will be less advantageous,
> than in tmpfs doing a large dd - the case I'm aiming not to regress here
> (tmpfs has been copying ZERO_PAGE(0) like this for years).

We do need something to get 5.18 fixed.  Christoph, do you think we
should proceed with this patch for 5.18?
