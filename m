Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43822 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab3A1VdH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 16:33:07 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130128160617.3288501c@tlielax.poochiereds.net>
Date: Mon, 28 Jan 2013 16:32:55 -0500
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Message-Id: <C741FD4B-4A16-4E43-A0C4-C638A47A6F32@oracle.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com> <1359402082-29195-2-git-send-email-jlayton@redhat.com> <5AD4F061-69A6-47F5-B20A-34B8DCC2EB5E@oracle.com> <20130128150502.4c5f497b@tlielax.poochiereds.net> <321A7110-AD03-49EB-A158-246FC8BD24E1@oracle.com> <20130128152643.2b136d37@tlielax.poochiereds.net> <615875E4-820D-487E-99CF-9ABD46121966@oracle.com> <20130128154555.3a93c6dc@tlielax.poochiereds.net> <F6E767BA-D9F9-49FE-AABB-75EA20AF827A@oracle.com> <20130128160617.3288501c@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 28, 2013, at 4:06 PM, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 28 Jan 2013 15:54:26 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Since we don't know for sure how this works, we should have someone create unit tests to explore this, fix any bugs that are discovered, and ensure that it continues to work.
>> 
> 
> I'm fairly sure I understand how it works (though I did need to go back
> and refresh my memory here). I'm not sure how you'd go about writing
> such a test for this, but let me know if you do and I'll be happy to
> take a look.

I guess I'm abusing the term "unit test."  I mean simply that someone has a set up that uses link-local addresses and tries all the typical NFSv4 tests with it, and especially the ones that involve the DRC.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




