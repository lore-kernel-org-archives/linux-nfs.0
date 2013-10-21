Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab3JUQyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 12:54:33 -0400
Message-ID: <52655C68.1000604@RedHat.com>
Date: Mon, 21 Oct 2013 12:55:04 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Add -s option.
References: <1380734389-8202-1-git-send-email-tasleson@redhat.com> <20131002214015.GA20902@fieldses.org> <5265315D.9030008@RedHat.com> <20131021140114.GE18657@fieldses.org>
In-Reply-To: <20131021140114.GE18657@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 10:01, J. Bruce Fields wrote:
> On Mon, Oct 21, 2013 at 09:51:25AM -0400, Steve Dickson wrote:
>> I guess we could change -v to used what the -s is proposing,
>> but that could break someone's existing configuration...  
> 
> Also, looking at my home server....  It would be annoying to get:
> 
> 	/export *(rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 
> when all you need is:
> 
> 	/export <world>(rw,wdelay,insecure,no_root_squash,no_subtree_check)
> 
> (Actually I wonder why it's even showing wdelay and no_subtree_check
> when those are both defaults?  But this is on F16, maybe it's different
> now.  I should really update that machine.)
No, the defaults have not changed for (quite) a while... 
The defaults are: 
    ro, root_squash, wdelay, no_subtree_check

Now it turns out wdelay (aka NFSEXP_GATHERED_WRITES) is a v2 only thing... 
So do we really need to have that on by default, now that we are 
slowly moving away from v2 support?

steved.
