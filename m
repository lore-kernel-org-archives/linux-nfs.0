From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Python scripts for analyzing NFS/RPC metrics
Date: Mon, 23 Jun 2008 13:00:11 -0400
Message-ID: <485FD69B.9050902@RedHat.com>
References: <20080609163029.5461.35699.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195AbYFWRB2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 13:01:28 -0400
In-Reply-To: <20080609163029.5461.35699.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> As promised, here are the Python scripts that I've implemented for analyzing
> NFS and RPC performance metrics reported via /proc/self/mountstats.  They
> still need man pages and proper installation in the nfs-utils Makefile.
> 
> While we decide whether to install and support these scripts as they are, or
> to replace them with C language re-implementations, let's include them in
> nfs-utils now so folks can try them out, bugs can be addressed, and missing
> features provided.
All four patches committed...

steved.
