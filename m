Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45237 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbHRX76 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 19:59:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [BUG] nfs-utils broken with musl
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55D3AA7E.2050606@gmail.com>
Date: Tue, 18 Aug 2015 16:59:51 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F1351211-433D-4386-889B-BA023442CC13@oracle.com>
References: <55D3AA7E.2050606@gmail.com>
To: Tastky <tastky@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 18, 2015, at 2:58 PM, Tastky <tastky@gmail.com> wrote:

> As currently being discussed on musl's mailing list, there appears to be a bug in nfs-utils exposed by musl, which makes rpc.statd loop with:
> 
> my_svc_run() - select: Bad file descriptor
> 
> URL to list:
> http://www.openwall.com/lists/musl/2015/08
> The relevant messages begin at August 18 and have 'nfs-utils broken with musl: "select: Bad file descriptor"' in their titles.

Are you sure this isn't a libtirpc issue?


--
Chuck Lever



