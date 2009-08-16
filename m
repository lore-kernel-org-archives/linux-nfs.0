From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fix hang on access to NFSv4 subexports with sec=
Date: Sun, 16 Aug 2009 16:19:25 -0400
Message-ID: <4A8869CD.1040702@RedHat.com>
References: <20090721224938.GA20694@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52676 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbZHPUT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Aug 2009 16:19:29 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n7GKJUPb027017
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:19:30 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n7GKJUJk008480
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:19:30 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-26.bos.redhat.com [10.16.10.26])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n7GKJTPj012655
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2009 16:19:29 -0400
In-Reply-To: <20090721224938.GA20694@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/21/2009 06:49 PM, J. Bruce Fields wrote:
> Since
> 
> 	2d77e3a27b7b211f303f.. "Fix bug when both crossmnt and fsid are set"
> 
> Subexports automatically created by "crossmnt" get the NFSEXP_FSID flag
> cleared.  That flag should also be cleared in the
> security-flavor-specific flag fields.  Otherwise the kernel detects the
> inconsistent flags and rejects the export.
> 
> The symptoms are clients hanging the first time they export a filesystem
> mounted under a filesystem that was exported with something like:
> 
> 	/exports *(crossmnt,fsid=0,sec=krb5)
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
Committed...

steved.
