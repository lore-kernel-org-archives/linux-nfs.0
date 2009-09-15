From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] nfsv3: Use inode posix acl cache
Date: Tue, 15 Sep 2009 20:13:38 +0530
Message-ID: <20090915144338.GA24989@skywalker.linux.vnet.ibm.com>
References: <1251892788-497-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20090915083740.GA7884@skywalker.linux.vnet.ibm.com>
 <1253021706.4456.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:57810 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbZIOOnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 10:43:43 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8FEhjqL025135
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2009 20:13:45 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8FEhjug1228892
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2009 20:13:45 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8FEhioK024785
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2009 20:13:45 +0530
In-Reply-To: <1253021706.4456.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 15, 2009 at 09:35:06AM -0400, Trond Myklebust wrote:
> On Tue, 2009-09-15 at 14:07 +0530, Aneesh Kumar K.V wrote:
> > Any chance of getting this patch applied ?
> > 
> > -aneesh
> 
> AFAICS, it adds a dependency on CONFIG_FS_POSIX_ACL that needs to be
> resolved in Kconfig first.
> 
> Has it been tested, and if so what were the tests?
> 


I did a getfacl and setfacl test with two clients. If there is a test suite
that i need to run to get the patches tested please let me. I will add the
proper Kconfig dependency and sent a revised patch later.

-aneesh
