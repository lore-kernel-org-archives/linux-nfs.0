Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:15249 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080AbbDNTYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2015 15:24:00 -0400
Message-ID: <552D694D.5050200@Netapp.com>
Date: Tue, 14 Apr 2015 15:23:57 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Remove CONFIG_NFS_V4 checks from nfs_idmap.h
References: <1429036032-11204-1-git-send-email-Anna.Schumaker@Netapp.com> <20150414192217.GA20599@infradead.org>
In-Reply-To: <20150414192217.GA20599@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/14/2015 03:22 PM, Christoph Hellwig wrote:
> On Tue, Apr 14, 2015 at 02:27:12PM -0400, Anna Schumaker wrote:
>> The idmapper is completely internal to the NFS v4 module, so this macro
>> will always evaluate to true.  This patch also removes unnecessary
>> includes of this file from the generic NFS client.
> 
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Seems like the header should move to fs/nfs/ as well..
> 

Want me to send another patch moving the header?  Are there guidelines for when a header should be in include/ and when it should be in our subdirectory?

Anna
