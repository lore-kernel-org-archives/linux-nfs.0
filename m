Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282AbcF3Pne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 11:43:34 -0400
Subject: Re: /etc/exports parsing is borked again in nfs-utils
To: Trond Myklebust <trondmy@primarydata.com>
References: <1466885520.9316.4.camel@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9a09922f-5105-db85-628a-667a5d93867b@RedHat.com>
Date: Thu, 30 Jun 2016 11:42:35 -0400
MIME-Version: 1.0
In-Reply-To: <1466885520.9316.4.camel@primarydata.com>
Content-Type: text/plain; charset=windows-1252
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
When you say "succeed" what do you mean by that since your
are specifying both 'ro' and 'rw'.

steved.
