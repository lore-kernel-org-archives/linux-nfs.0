From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] mount: Fix po_join() call site in nfs_try_mount_v4()
Date: Tue, 03 Nov 2009 12:56:23 -0500
Message-ID: <4AF06EC7.8040307@RedHat.com>
References: <20091026210110.14346.90636.stgit@matisse.1015granger.net> <20091026210327.14346.15937.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbZKCR4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 12:56:22 -0500
In-Reply-To: <20091026210327.14346.15937.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/26/2009 05:03 PM, Chuck Lever wrote:
> Make sure the copied options string is freed in case po_join() fails.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 

Committed...

steved.

