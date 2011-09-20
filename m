Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1ITLgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 07:36:04 -0400
Message-ID: <4E787AA1.9050707@RedHat.com>
Date: Tue, 20 Sep 2011 07:36:01 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] Fixes for nfs-utils-1.2.next
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/12/2011 06:05 PM, Chuck Lever wrote:
> For review: eight patches that address some minor issues in and around
> sm-notify.
> 
> ---
> 
> Chuck Lever (8):
>       sm-notify: sm-notify leaves monitor records in sm.bak
>       sm-notify: Avoid extra rpcbind queries
>       sm-notify: Use correct retransmit timeout when sending a fresh RPC
>       sm-notify: Refactor insert_host() and recv_rpcbind_reply()
>       nfsumount: Squelch compiler warning
>       configure.ac: Add --with-statd-extension configure option
>       configure.ac: Clean up help string for --enable-mount
>       configure.ac: Fix help string for --with-statedir= option
> 
Committed all of these except for the one adding the 
statd-extension configure option..

steved.
