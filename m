From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Date: Mon, 1 Nov 2010 16:33:15 -0400
Message-ID: <20101101203315.GA3600@elliptictech.com>
References: <20101101175854.GA3550@elliptictech.com>
 <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com>
 <20101101181938.GA3875@elliptictech.com>
 <187AEE96-9231-4899-9D65-A444503D2758@oracle.com>
 <1288639376.5009.16.camel@heimdal.trondhjem.org>
 <1288640536.5009.18.camel@heimdal.trondhjem.org>
 <DA1E14E0-DCCD-4A6D-9471-E627D4BF2E85@oracle.com>
 <1288640888.5009.19.camel@heimdal.trondhjem.org>
 <1288642170.5009.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288642170.5009.23.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-01 16:09 -0400, Trond Myklebust wrote:
> Urgh, but nlmclnt_bind_host() will still set .saddress.
> 
> OK. Here is take 2 of the patch...
[...]
> NLM: Fix a regression in lockd

Problem occurs with this one (on top of 2.6.37-rc1), too :(

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
