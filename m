From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfsv3: Use inode posix acl cache
Date: Tue, 15 Sep 2009 09:35:06 -0400
Message-ID: <1253021706.4456.5.camel@heimdal.trondhjem.org>
References: <1251892788-497-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20090915083740.GA7884@skywalker.linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25956 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753442AbZIONfw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 09:35:52 -0400
In-Reply-To: <20090915083740.GA7884-6yE53ggjAfyuJw1Jpgb2kA4V1jybR7bhVpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-15 at 14:07 +0530, Aneesh Kumar K.V wrote:
> Any chance of getting this patch applied ?
> 
> -aneesh

AFAICS, it adds a dependency on CONFIG_FS_POSIX_ACL that needs to be
resolved in Kconfig first.

Has it been tested, and if so what were the tests?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
