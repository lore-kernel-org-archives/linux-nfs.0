Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44714 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751069Ab0HRUlM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:41:12 -0400
Message-ID: <4C6C4565.1070603@panasas.com>
Date: Wed, 18 Aug 2010 23:41:09 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/4] fix up xdr_shrink_pagelen
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond, the following 3 patches fix and clean up xdr_shrink_pagelen.

The main issue is that buf->buflen -= len is potentially done
twice.  The rest are cosmetic clean ups that simplify the code a bit.

[PATCH 1/4] sunrpc: don't shorten buflen twice in xdr_shrink_pagelen
[PATCH 2/4] sunrpc: clean up xdr_shrink_pagelen use of temporary pointer
[PATCH 3/4] sunrpc: don't use the copy variable in nested block
[PATCH 4/4] sunrpc: simplify xdr_shrijk_pagelen use of "copy"

Benny
