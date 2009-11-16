From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: NFSv4: fix backgrounding
Date: Mon, 16 Nov 2009 13:43:03 -0500
Message-ID: <4B019D37.9090608@RedHat.com>
References: <1257435088.2984.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Harshula Jayasuriya <harshula@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769AbZKPSm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 13:42:58 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAGIh4Ut013615
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2009 13:43:04 -0500
In-Reply-To: <1257435088.2984.66.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/05/2009 10:31 AM, Harshula Jayasuriya wrote:
> Hi,
> 
> The nfsmount() function checks if !bg before running
> switch(rpc_createerr.cf_stat). On the other hand, the nfs4mount()
> function does not, and results in exiting the loop on the first
> iteration even with the bg mount option.
> 
> NOTE: This and the previous patch ("nfs-utils: mount options can be lost
> when using bg option") are relevant to non text-based mount options.
> 
> See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Committed...

steved.
