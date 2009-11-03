From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount.nfs: Assume v2/v3 if mount-related options
 are	present
Date: Tue, 03 Nov 2009 12:55:59 -0500
Message-ID: <4AF06EAF.6010009@RedHat.com>
References: <20091026210110.14346.90636.stgit@matisse.1015granger.net> <20091026210319.14346.20494.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400AbZKCRz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 12:55:58 -0500
In-Reply-To: <20091026210319.14346.20494.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/26/2009 05:03 PM, Chuck Lever wrote:
> Don't try NFSv4 if any MNT protocol related options were presented by
> the user.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Committed..

steved
