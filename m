From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] svcsock: Add a reference to sunrpc in svc_addsock
Date: Mon, 24 Nov 2008 10:25:10 -0500
Message-ID: <x491vx1f8o9.fsf@segfault.boston.devel.redhat.com>
References: <1227449316-27946-1-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, jlayton@redhat.com, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55907 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbYKXPZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 10:25:15 -0500
In-Reply-To: <1227449316-27946-1-git-send-email-tom@opengridcomputing.com>
	(Tom Tucker's message of "Sun, 23 Nov 2008 08:08:36 -0600")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Tucker <tom@opengridcomputing.com> writes:

> The svc_addsock function adds transport instances without taking a
> reference on the sunrpc.ko module, however, the generic transport
> destruction code drops a reference when a transport instance
> is destroyed.
>
> Add a try_module_get call to the svc_addsock function for transport
> instances added by this function.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Tested-by: Jeff Moyer <jmoyer@redhat.com>
