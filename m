Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab3JXFeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 01:34:04 -0400
Message-ID: <5268B148.6070204@redhat.com>
Date: Thu, 24 Oct 2013 00:34:00 -0500
From: Tony Asleson <tasleson@redhat.com>
Reply-To: tasleson@redhat.com
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <20131022092519.4f4683a8@notabene.brown> <52669862.6030409@redhat.com> <20131023124444.65ace6e3@notabene.brown> <52680917.4010509@redhat.com> <20131024091811.34b06e71@notabene.brown>
In-Reply-To: <20131024091811.34b06e71@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/23/2013 05:18 PM, NeilBrown wrote:
> On Wed, 23 Oct 2013 12:36:23 -0500 Tony Asleson <tasleson@redhat.com> wrote:
>> For example, if the strdup call fails in function client_init, we fail
>> the operation and return exit value of 0.  Unlikely, but just the first
>> example I stumbled across.
> 
> I think it is a lot closer to "impossible" than just "unlikely".
> malloc doesn't fail in this sort of context, the OOM killer kills something
> off instead.
> My personal preference is to replace all malloc/calloc/strdup calls with
> the xmalloc, xstrdup etc calls in support/nfs/xcommon.c.
> If you are worried about malloc failing, I'd much prefer to see a patch which
> changes nfs-utils to use those uniformly.

Sorry, my real point was that there are other ways for exportfs to fail
to do the operation and fail to report it, thus the reason my patch was
more invasive.  I will try to find another more likely example that
illustrates this.

Regards,
Tony
