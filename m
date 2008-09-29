From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount option
 descriptions
Date: Mon, 29 Sep 2008 07:37:18 -0400
Message-ID: <48E0BDEE.2030605@RedHat.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net> <20080923161636.5119.54434.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42389 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939AbYI2Ljm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 07:39:42 -0400
In-Reply-To: <20080923161636.5119.54434.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Mike Eisler noted that the use of the term "netid" in the descriptions
> of the "proto=" option is not appropriate, since Linux does not allow
> "udp6" or "tcp6".
> 
> Remove the term "netid" from nfs(5).
Committed... using the word "transport" instead of "prot" as suggested by Tom.

steved.
