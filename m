Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:42670 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755549Ab1ALTRa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 14:17:30 -0500
Date: Wed, 12 Jan 2011 14:17:27 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Regression, bisected: NFS O_EXCL breakage in 2.6.37 client.
Message-ID: <20110112191727.GA4349@elliptictech.com>
References: <20110112161054.GA3431@elliptictech.com>
 <1294856889.2971.43.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294856889.2971.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-12 13:28 -0500, Trond Myklebust wrote:
> Subject: [PATCH] NFS: Fix NFSv3 exclusive open semantics

Seems to have fixed the problem, thanks!

Tested-by: Nick Bowler <nbowler@elliptictech.com>

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
