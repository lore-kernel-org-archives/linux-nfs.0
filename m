Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5B1DC10F14
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 14:38:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6BAF221738
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 14:38:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727831AbfDWOiy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Apr 2019 10:38:54 -0400
Received: from mx1.redhat.com ([209.132.183.28]:56872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726421AbfDWOiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Apr 2019 10:38:54 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8837330024D0;
        Tue, 23 Apr 2019 14:38:50 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-126-49.rdu2.redhat.com [10.10.126.49])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4E1416013D;
        Tue, 23 Apr 2019 14:38:49 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id A7AB51803A0; Tue, 23 Apr 2019 10:38:48 -0400 (EDT)
Date:   Tue, 23 Apr 2019 10:38:48 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     NeilBrown <neilb@suse.com>
Cc:     Doug Nazar <nazard@nazar.ca>, linux-nfs@vger.kernel.org
Subject: Re: nfsd bug after f875a792abe9 (nfsd: allow nfsv3 readdir request
 to be larger.)
Message-ID: <20190423143848.GA9302@parsley.fieldses.org>
References: <5b98d3d5-4b80-8783-b212-4fd7ab9b1006@nazar.ca>
 <87tvep6066.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tvep6066.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 23 Apr 2019 14:38:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 23, 2019 at 10:21:53AM +1000, NeilBrown wrote:
> On Sat, Apr 20 2019, Doug Nazar wrote:
> 
> > After recently upgrading the kernel on one of my servers I was getting 
> > the below crashes. Tracked it down to an NFSv3 root client, bisection 
> > points to f875a792abe9. A revert of that on top of 
> > 5.1.0-rc5-00289-gee2725f711fa works fine.
> 
> hi Doug,
>  thanks for the report and for bisecting!
> 
> I think this bug has been fixed, but the fix hasn't landed upstream yet.
> If you
>    git pull git://git.linux-nfs.org/~bfields/linux.git nfs-next
> 
> you should get
> 
> Commit 3c86794ac0e6 ("nfsd/nfsd3_proc_readdir: fix buffer count and page pointers")
> 
> which should fix this.
> 
> 
> Bruce:  I don't see that patch in your "for-5.1" branch, but you said
>    "Queuing up for 5.1."
> Did something go awry?

Sorry, I've got this confusing system where I commit first to a branch
named for-x.y-incoming, then push it to for-x.y after I've tested it.
Except sometimes I forget to push to the for-x.y branch until the last
minute.

The -incoming branches should always be included in nfsd-next.

Anyway, I'll send a pull request now, it's overdue....

--b.
