Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A8ECC433ED
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Apr 2021 03:57:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2379F60FE8
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Apr 2021 03:57:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234258AbhDVD5s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Apr 2021 23:57:48 -0400
Received: from mail.kernel.org ([198.145.29.99]:41538 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229536AbhDVD5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Apr 2021 23:57:48 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 68F9E613E0;
        Thu, 22 Apr 2021 03:57:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1619063834;
        bh=QlWwdprMt2Kc9yJ/6D6n6mMFBdEaVscgEP+0IDmaR/M=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=WJdgWqQWfv0ItM4Ef4GhFlh6L1uueZBCKq1vci709noRw1y8S/VEHAlxDJpR0a80g
         LUX4NxExeLP8rKkzj7JoK+FG4M/S2/4wtaMHf2DUDbH+TeXmqHBmS0PGvdlhX5HSzt
         bUq1C2hBxJhe4I09ngf78I6DgxLpYkuH7kKogZUc6hQqrKR/6Uc71+AM+tvK2F8UNv
         pnRiKMdVdUzF2yslSDcWlu4NUXR2V/beF/ja7TYohDTUlfabEn4gNzTNjcKxH4Hkn9
         Uf1gdFfM5rr7Cchbl8CDNZ993lItzgllORf5/R767XPISc21LDDuCuulFZxyWxQMa8
         obnJrXEJEkIuA==
Date:   Thu, 22 Apr 2021 06:57:10 +0300
From:   Leon Romanovsky <leon@kernel.org>
To:     Mike Rapoport <rppt@kernel.org>
Cc:     Theodore Ts'o <tytso@mit.edu>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Greg KH <gregkh@linuxfoundation.org>,
        Aditya Pakki <pakki001@umn.edu>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Dave Wysochanski <dwysocha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Add a check for gss_release_msg
Message-ID: <YID0Fg3f0PzckJI9@unreal>
References: <20210407001658.2208535-1-pakki001@umn.edu>
 <YH5/i7OvsjSmqADv@kroah.com>
 <20210420171008.GB4017@fieldses.org>
 <YH+zwQgBBGUJdiVK@unreal>
 <CAFX2JfnGCbanTaGurArBw-5F2MynPD=GpwkfU6wVoNKr9ffzRg@mail.gmail.com>
 <YIAzfsMx6bn5Twu8@unreal>
 <YIBJXjCbJ1ntH1RF@mit.edu>
 <YIBiQ3p9z7y6PeqT@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <YIBiQ3p9z7y6PeqT@kernel.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 21, 2021 at 08:34:59PM +0300, Mike Rapoport wrote:
> On Wed, Apr 21, 2021 at 11:48:46AM -0400, Theodore Ts'o wrote:
> > On Wed, Apr 21, 2021 at 05:15:26PM +0300, Leon Romanovsky wrote:
> > > > This thread is the first I'm hearing about this. I wonder if there is
> > > > a good way of alerting the entire kernel community (including those
> > > > only subscribed to subsystem mailing lists) about what's going on? It
> > > > seems like useful information to have to push back against these
> > > > patches.
> 
> Heh, I've got this information from google news feed on my phone :)
>  
> > > IMHO, kernel users ML is good enough for that.
> > 
> > The problem is that LKML is too high traffic for a lot of people to
> > want to follow.
> 
> I think Leon meant kernel.org users ML (users@linux.kernel.org). Along with
> ksummut-discuss it'll reach most maintainers, IMHO.

Exactly.

Thanks

>  
> > There are some people who have used the kernel summit discuss list
> > (previously ksummit-discuss@lists.linux-foundation.org, now
> > ksummit@lists.linux.dev) as a place where most maintainers tend to be
> > subscribed, although that's not really a guarantee, either.  (Speaking
> > of which, how to handle groups who submit patches in bad faith a good
> > Maintainer Summit topic for someone to propose...)
> 
> -- 
> Sincerely yours,
> Mike.
