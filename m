Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36357 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729AbcCOMoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 08:44:08 -0400
Received: by mail-lb0-f179.google.com with SMTP id x1so20885488lbj.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Mar 2016 05:43:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160314203846.GA22276@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Tue, 15 Mar 2016 13:43:37 +0100
Message-ID: <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall()
 detects a race
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Mar 14, 2016 at 9:38 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Sorry for the delay.  I agree, it seems simple enough; applying for
> 4.6....

It it something we can consider for stable?

Thanks,
-- 
William
