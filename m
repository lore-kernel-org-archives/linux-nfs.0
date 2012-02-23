Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177Ab2BWQ6R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Feb 2012 11:58:17 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1329845288-13238-1-git-send-email-bjschuma@netapp.com>
References: <1329845288-13238-1-git-send-email-bjschuma@netapp.com>
To: bjschuma@netapp.com
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        iisaman@netapp.com, William.Adamson@netapp.com
Subject: Re: [PATCH 1/2] Created a function for setting timeouts on keys
Date: Thu, 23 Feb 2012 16:58:11 +0000
Message-ID: <30287.1330016291@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@netapp.com wrote:

> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> The keyctl_set_timeout function isn't exported to other parts of the
> kernel, but I want to use it for the NFS idmapper.  I already have the
> key, but I wanted a generic way to set the timeout.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

Acked-by: David Howells <dhowells@redhat.com>
