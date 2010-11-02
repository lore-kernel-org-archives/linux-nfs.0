Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:44098 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752962Ab0KBOGu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Nov 2010 10:06:50 -0400
Date: Tue, 2 Nov 2010 10:05:33 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Message-ID: <20101102140533.GA3695@elliptictech.com>
References: <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com>
 <20101101181938.GA3875@elliptictech.com>
 <187AEE96-9231-4899-9D65-A444503D2758@oracle.com>
 <1288639376.5009.16.camel@heimdal.trondhjem.org>
 <1288640536.5009.18.camel@heimdal.trondhjem.org>
 <DA1E14E0-DCCD-4A6D-9471-E627D4BF2E85@oracle.com>
 <1288640888.5009.19.camel@heimdal.trondhjem.org>
 <1288642170.5009.23.camel@heimdal.trondhjem.org>
 <20101101203315.GA3600@elliptictech.com>
 <1288703671.2925.1.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288703671.2925.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-02 09:14 -0400, Trond Myklebust wrote:
> OK. Can you please try the following? It only differs from the last one
> by a small bugfix, and a WARN_ON() in order to try to catch other
> occurrences of the same bug.
[...]
> NLM: Fix a regression in lockd

Things seem to be working fine now, thanks.

Tested-by: Nick Bowler <nbowler@elliptictech.com>

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
