From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH/RFC] svcgssd always sets an infinite expiry on authentication
 tokens etc.
Date: Tue, 02 Dec 2008 11:04:08 -0500
Message-ID: <49355C78.6080607@RedHat.com>
References: <18740.50457.981544.21225@notabene.brown> <4d569c330812012145y2353bc9asd7a0c62fef42ed3a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50491 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbYLBQIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2008 11:08:42 -0500
In-Reply-To: <4d569c330812012145y2353bc9asd7a0c62fef42ed3a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Coffman wrote:
> Hi Neil,
> This seems reasonable.
> 
> I have a patch somewhere that gets the actual Kerberos expiration that
> could be used for the rsc timeout.  But I think this should be fine
> for now.  (Perhaps at the cost of requiring clients to negotiate a new
> context every hour?)
This question is a bit worrisome, imho... I understand the need to release
memory consumed by dead contexts but on the other hand, renegotiating
contexts every hour on the hours seems a bit costly as well... 

Does it make sense to make this time out configurable? Yes, it would be
a very obscure knob, but in the unlikely event there is a bug in the 
renegotiating code or renegotiating simply becomes too costly, I think
it would good to have a way to dial the time out back up as a work-around.

steved.

