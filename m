Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:21344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934535AbaKNPGm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 10:06:42 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] KEYS: Ensure expired keys are renewed
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <17508.1415967632@warthog.procyon.org.uk>
Date: Fri, 14 Nov 2014 09:06:39 -0600
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <48198F2A-23E5-486A-9E75-7A1CF59627BC@oracle.com>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net> <17508.1415967632@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 14, 2014, at 6:20 AM, David Howells <dhowells@redhat.com> wrote:

> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> -	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
>> -		ctx->flags &= ~KEYRING_SEARCH_DO_STATE_CHECK;
> 
> The problem is that this adversely affects keyring cycle checking and
> possession checking.  Those absolutely must suppress the state check.

Thanks for the review.

OK, I feared there could be side effects of restoring the original
API contract, but hoped there would not be.

It’s this code:

      if (ctx->match_data.lookup_type == KEYRING_SEARCH_LOOKUP_ITERATE ||
          keyring_compare_object(keyring, &ctx->index_key)) {
               ctx->skipped_ret = 2;
               ctx->flags |= KEYRING_SEARCH_DO_STATE_CHECK;

that flips DO_STATE_CHECK back on in some cases, right?

Any suggestions?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



