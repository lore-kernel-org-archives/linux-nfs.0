From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] rpc.statd: eliminate --secure_statd
Date: Thu, 4 Sep 2008 16:08:54 +1000
Message-ID: <18623.31606.828680.632520@notabene.brown>
References: <20080902215132.31328.44934.stgit@manray.1015granger.net>
	<20080902215354.31328.21471.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, okir@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54388 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbYIDGJE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 02:09:04 -0400
In-Reply-To: message from Chuck Lever on Tuesday September 2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday September 2, chuck.lever@oracle.com wrote:
> -	/* Restrict access to statd.
> -	 * In the light of CERT CA-99.05, we tighten access to
> -	 * statd.			--okir
> -	 */

This is my only concern.  You've removed the reference to CERT
CA-99.05.
Maybe put it back in the new "caller_is_localhost" function??

Otherwise
 Acked-By: NeilBrown <neilb@suse.de>

