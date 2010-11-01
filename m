From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Date: Mon, 1 Nov 2010 15:59:58 -0400
Message-ID: <20101101195958.GA3598@elliptictech.com>
References: <20101101175854.GA3550@elliptictech.com>
 <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com>
 <20101101181938.GA3875@elliptictech.com>
 <187AEE96-9231-4899-9D65-A444503D2758@oracle.com>
 <1288639376.5009.16.camel@heimdal.trondhjem.org>
 <1288640536.5009.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:48546 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752763Ab0KAUAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 16:00:25 -0400
In-Reply-To: <1288640536.5009.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-01 15:42 -0400, Trond Myklebust wrote:
> On Mon, 2010-11-01 at 15:22 -0400, Trond Myklebust wrote:
> Does this fix the regression?
[...]
> NLM: Fix a regression in lockd

Unfortunately, the problem persists with this patch applied on top of
2.6.37-rc1.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
