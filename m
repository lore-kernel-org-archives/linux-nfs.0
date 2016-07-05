Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbcGESp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 14:45:59 -0400
Subject: Re: /etc/exports parsing is borked again in nfs-utils
To: Trond Myklebust <trondmy@primarydata.com>
References: <1466885520.9316.4.camel@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <151cf713-410a-b073-5c5a-430691fb5e6d@RedHat.com>
Date: Tue, 5 Jul 2016 14:45:58 -0400
MIME-Version: 1.0
In-Reply-To: <1466885520.9316.4.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/25/2016 04:12 PM, Trond Myklebust wrote:
> [root@leira nfs]# cat /etc/exports
> /export		-ro,sec=sys,sync	localhost(rw,no_root_squ
> ash)
> [root@leira nfs]# exportfs -rv
> exporting localhost:/export
> [root@leira nfs]# mount -t nfs localhost:/export /mnt/nfs
> [root@leira nfs]# mkdir /mnt/nfs/gnurr
> mkdir: cannot create directory ‘/mnt/nfs/gnurr’: Read-only file system
> 
> 
> Note that removing the "sec=sys" above causes the test to succeed.
> 
Well it has something to do with

commit 9b5c3c6a6571a265a90cfce30345891fac24a67c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Sep 18 11:50:58 2013 -0400

    exportfs: insecure/secure should be a secinfo_flag

Because I commit out the call to secinfo_flags_show(), 
the export is exported correctly... still looking... 

steved.
