Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:40836 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755426Ab2EHTv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 15:51:28 -0400
From: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
To: <linux-nfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <9c0b78d1.00001bd8.00000533@aldep-VC.vmware.com> <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
In-Reply-To: <1508773761.4854678.1335731939770.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
Subject: RE: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
Date: Tue, 8 May 2012 12:51:28 -0700 (PDT)
Message-ID: <a4ab669d.00001670.0000002d@aldep-VC.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
> Sent: Friday, April 27, 2012 4:51:20 PM
> Subject: Re: About Direct I/O
>
> On Fri, Apr 27, 2012 at 01:22:46PM -0700, Alexandre Depoutovitch
> wrote:

> >
> > The tests have been done on a hardware RAID10 array with 8 10K 450GB
> > SAS drives. Raid adapter was HP P410i.
>
> It might be worth also testing with a single drive if you want to see
> the worst case for synchronous writes.  (That adapater may have a
> battery-backed cache that lets it respond to writes immediately?)

Yes, the adapter has battery backed cache (1GB), and you are right, it is 
the main reason for significant improvement when doing direct I/O. Sync 
random writes happen order of magnitude faster than reads. I also tested 
Direct I/O on a cheap Western Digital 7.2K SATA drive (WD10EALX) on an Intel 
82801 SATA controller. There was no performance gain with direct I/O because 
write speed was in fact 1.5 slower than read speed. However, there was no 
performance degradation either, whether direct of buffered I/O was used (in 
sync mode).
So looks like that Direct I/O for NFS is beneficial for random, f/s 
unaligned,  synchronous writes on adapters with NVRAM. In other cases it can 
be turned on/off either automatically, based on alignment and O_SYNC flag, 
or manually, based on hardware characteristics.

Alex
