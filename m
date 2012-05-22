Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165Ab2EVNAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 09:00:17 -0400
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
In-Reply-To: <20120522124728.GB891@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-4-git-send-email-simo@redhat.com>
	 <20120522124728.GB891@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 May 2012 09:00:07 -0400
Message-ID: <1337691607.16840.178.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-22 at 08:47 -0400, J. Bruce Fields wrote:
> Have you and Stanislav talked about fitting this with the ongoing
> container work?

No, I wanted to make it work for the normal case first, I assume it will
be simple enough to change the code to work with containers later.
Main reason is that I have no way to test containerized stuff.

If I understand it correctly, all is needed is to allow attaching to
different sockets for different containers ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

