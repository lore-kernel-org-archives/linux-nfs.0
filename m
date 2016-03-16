Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36847 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbcCPQRO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2016 12:17:14 -0400
Received: by mail-lb0-f173.google.com with SMTP id x1so51089845lbj.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 09:17:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160316160017.GF11520@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
 <20160315131959.GA419@fieldses.org> <87vb4nh406.fsf@notabene.neil.brown.name>
 <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com>
 <20160316150510.GE11520@fieldses.org> <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
 <20160316160017.GF11520@fieldses.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 16 Mar 2016 17:16:40 +0100
Message-ID: <CAJ75kXZCzku17QPe_Jj4yt7w4re7wwiwmng8axYdZZ1d_3Ew6A@mail.gmail.com>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall()
 detects a race
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 5:00 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> OK.  I'd be interested in your use case if you get the chance.

Well, in our case, we have temporary instances which mount the needed
filesystem in order to do temporary work and clean it before leaving.
In other cases, there is only one connection by nfs server and all the
filesystems are bind to it.

Thanks,
-- 
William
