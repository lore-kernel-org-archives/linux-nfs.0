From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] lockd: Add address family-agnostic helper for
	zeroing the port number
Date: Wed, 27 Aug 2008 09:55:27 -0400
Message-ID: <20080827135527.GA2018@fieldses.org>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164232.20488.11685.stgit@manray.1015granger.net> <20080826190319.GF4380@fieldses.org> <20080826191750.GH4380@fieldses.org> <BE820CD5-33E0-4F61-B6C9-90FFEAB9F6D4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-Onf44Ee+mfbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955AbYH0Nza (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2008 09:55:30 -0400
In-Reply-To: <BE820CD5-33E0-4F61-B6C9-90FFEAB9F6D4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2008 at 03:56:12PM -0400, Chuck Lever wrote:
> On Aug 26, 2008, at Aug 26, 2008, 3:17 PM, J. Bruce Fields wrote:
>> On Tue, Aug 26, 2008 at 03:03:19PM -0400, bfields wrote:
>>> It would be nice if not necessary just to move nfs_set_port()  
>>> somewhere
>>> common and use that (maybe with a more generic name).
>>>
>>> That aside, all 5 patches are OK by me.
>>
>> Provisionally applied all but the first (purely client-side) patch to
>>
>> 	git://linux-nfs.org/~bfields/linux.git for-2.6.28
>>
>> Do you have any good regression tests for nsm?
>
> Netapp is providing some testing resources.  Their lock recovery tests  
> provide some test coverage, but I don't know details.

OK.  If they've got it in a form that's easy to distribute and use I'd
like to be able to run something like that here to test some of my work
in progress.

> One of the issues on the list for the Austin bake-a-thon is to review  
> our test coverage, and see if we can flesh this out more.

I won't be able to make it to Austin but I'll be interested in whatever
you find out.

--b.
