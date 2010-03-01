From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH][nfs-utils] configuration: Fix a typo in configure.ac
Date: Mon, 01 Mar 2010 07:57:28 -0500
Message-ID: <4B8BB9B8.8040703@RedHat.com>
References: <1266709510.3507.1.camel@localhost.localdomain> <20100222182202.GB11356@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab0CAM5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 07:57:39 -0500
In-Reply-To: <20100222182202.GB11356@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/22/2010 01:22 PM, J. Bruce Fields wrote:
> On Sat, Feb 20, 2010 at 03:45:10PM -0800, Trond Myklebust wrote:
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>
>> Fix a typo in commit 6d5ac3fa (nfsd: Disble NFS 4.1 functionality by default).
> 
> Better: please just rever 6d5ac3fa and apply
> http://marc.info/?l=linux-nfs&m=126540028610022&w=2
The problem I saw with the this patch was it would take 
a code change to re-enable the 4.1 functional, verses a
enabling a configuration flag. Plus, there has been a 
precedence set of having these types of configuration flags,
note the enable_nfsv3, enable_nfsv4, so adding a enable_nfsv41
seem to me made sense...

> 
> 	- distributions shouldn't be turning on 4.1 by default yet.
Its not... If the --enable_nfsv41 is not set, the 4.1 functional is
off. Having this type of flag enables the distros to enable the
functionality on development kernels but disable it on stable 
kernels, without any additional patches. Again to me, its seems
like the cleanest way to do it... 

> 	- In addition to the bug Trond found, 6d5ac3fa also
> 	  inadvertently disables -N4 in the disable_nfsv41 case.
Fixed...

steved.
