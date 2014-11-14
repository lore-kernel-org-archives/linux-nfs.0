Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981AbaKNMUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Nov 2014 07:20:38 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] KEYS: Ensure expired keys are renewed
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 14 Nov 2014 12:20:32 +0000
Message-ID: <17508.1415967632@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> wrote:

> -	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
> -		ctx->flags &= ~KEYRING_SEARCH_DO_STATE_CHECK;

The problem is that this adversely affects keyring cycle checking and
possession checking.  Those absolutely must suppress the state check.

David
