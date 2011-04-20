Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755630Ab1DTTXN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 15:23:13 -0400
Subject: RE: [pnfs] pnfs read layoutget
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Halevy, Benny" <bhalevy@panasas.com>
Cc: quanli gui <gqlxj1987@gmail.com>, linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <7225594ED4A1304C9E43D030A886D221F4CAC6@daytona.int.panasas.com>
References: <BANLkTi=tOYjnmfsRw+5HXShR4EGd5wsKFw@mail.gmail.com>
	 <7225594ED4A1304C9E43D030A886D221F4CAC6@daytona.int.panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 15:23:11 -0400
Message-ID: <1303327391.23206.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 11:05 -0400, Halevy, Benny wrote:
> This seems like a bug.

In 2.6.36?

> If I remember correctly, you are testing the files layout, right?
> Does this also happen with the latest kernel v2.6.39-rc3
> and / or pnfs-all-2.6.38?

We should definitely be calling layoutget from the 2.6.39-rc3 read code
assuming that the files layout module is being correctly loaded and that
the server is correctly advertising pNFS capabilities.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

