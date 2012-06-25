Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820Ab2FYU0s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jun 2012 16:26:48 -0400
Subject: nfs root problem in linux-next
From: Mark Salter <msalter@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-next <linux-next@vger.kernel.org>, linux-nfs@vger.kernel.org
Date: Mon, 25 Jun 2012 16:26:45 -0400
Content-Type: text/plain; charset="us-ascii"
Message-ID: <1340656006.20557.30.camel@deneb.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of Friday's linux-next I've been unable to successfully boot using an
nfs root with a c6x board. I bisected it to this patch:

  commit cc3b296fd9a01c9e654bcb9373af70dd6e32fb24
  Author: Trond Myklebust <Trond.Myklebust@netapp.com>
  Date:   Thu Jun 21 14:53:10 2012 -0400

      SUNRPC: Clean up xdr_read_pages and xdr_enter_page

I placed "good-boot" and "bad-boot" packet capture files at:

  http://people.redhat.com/~msalter/linux-next/

The only difference in the kernels used is the above patch. The
bad-boot mounted the nfs root but was unable to find the init
file which caused a panic. The nfsroot= parameter uses v3,tcp
flags and the server side is running rhel6.

I'm not at all familiar with the nfs code, but can help with
testing or providing any addtional info needed.

--Mark


