From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: mount options can be lost when using bg option
Date: Mon, 16 Nov 2009 13:43:26 -0500
Message-ID: <4B019D4E.7080406@RedHat.com>
References: <1257429825.2984.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Harshula Jayasuriya <harshula@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbZKPSnV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 13:43:21 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAGIhRc1007516
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2009 13:43:27 -0500
In-Reply-To: <1257429825.2984.26.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/05/2009 09:03 AM, Harshula Jayasuriya wrote:
> Hi,
> 
> When mounting an NFS export *without* the "bg" option, try_mount() is
> called only once. Before calling it, the variables mount_opts and
> extra_opts are set up. Then try_mount() calls nfsmount(), the latter
> assumes that the aforementioned variables can be modified. Most
> significantly, it allows the variable extra_opts to be modified.
> 
> When the "bg" mount option is used *and* the first try_mount() attempt
> fails, it daemonizes the process and calls try_mount() again,
> unfortunately, we've lost the required mount options in the variable
> extra_opts.
> 
> See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Committed...

steved.
