Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36646 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873Ab2AYOle (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 09:41:34 -0500
Date: Wed, 25 Jan 2012 09:41:31 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
Message-ID: <20120125144131.GC17873@fieldses.org>
References: <4EFB330A.7070908@parallels.com>
 <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com>
 <4EFB521B.7060004@parallels.com>
 <406C7E87-0CCB-4034-8FD8-1602F7DCDBD6@oracle.com>
 <4EFC5391.7000601@parallels.com>
 <5E291DB3-7FB3-4108-B254-B59780C64346@oracle.com>
 <4EFC9189.5040605@parallels.com>
 <56767BFA-62B8-4E10-B9B3-4FD9EF278969@oracle.com>
 <4EFCA668.6040107@parallels.com>
 <4F1FE3A8.5020002@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F1FE3A8.5020002@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 03:12:40PM +0400, Stanislav Kinsbursky wrote:
> Chuck, Bruce, have you seen this patch I'm replying to?
> I would appreciate for any comments with this problem.
> Also, probably we can instead just perform local transports socket
> connection in sync mode? This should solve our problem.
> What do you think?

I'm hoping Chuck will answer....

(I'd recommend just resending the patch, though; it's more likely to get
a response than if readers need to go dig the original out of mail
archives.)

--b.
