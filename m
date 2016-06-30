Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:60264 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932692AbcF3QAg convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 12:00:36 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Dickson Steve <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: /etc/exports parsing is borked again in nfs-utils
Date: Thu, 30 Jun 2016 15:59:59 +0000
Message-ID: <658F0E02-7B83-41AC-AE8F-03E258BEBD68@primarydata.com>
References: <1466885520.9316.4.camel@primarydata.com>
 <9a09922f-5105-db85-628a-667a5d93867b@RedHat.com>
In-Reply-To: <9a09922f-5105-db85-628a-667a5d93867b@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 30, 2016, at 11:42, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
> On 06/25/2016 04:12 PM, Trond Myklebust wrote:
>> [root@leira nfs]# cat /etc/exports
>> /export		-ro,sec=sys,sync	localhost(rw,no_root_squ
>> ash)
>> [root@leira nfs]# exportfs -rv
>> exporting localhost:/export
>> [root@leira nfs]# mount -t nfs localhost:/export /mnt/nfs
>> [root@leira nfs]# mkdir /mnt/nfs/gnurr
>> mkdir: cannot create directory ‘/mnt/nfs/gnurr’: Read-only file system
>> 
>> 
>> Note that removing the "sec=sys" above causes the test to succeed.
> When you say "succeed" what do you mean by that since your
> are specifying both 'ro' and 'rw’.

I expect the default option specification (i.e. ‘ro’) to be overridden by the host-specific option. That’s how it used to work, and I know, because I had to fix it once already.

Cheers
  Trond

