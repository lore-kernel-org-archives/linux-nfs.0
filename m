Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:34423 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644AbaDWNPN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 09:15:13 -0400
Message-ID: <5357BCD9.2@panasas.com>
Date: Wed, 23 Apr 2014 16:15:05 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <5357B827.8040506@panasas.com>
In-Reply-To: <5357B827.8040506@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2014 03:55 PM, Boaz Harrosh wrote:
> On 04/18/2014 12:09 AM, Anna Schumaker wrote:
<>
> yes please keep
> it on a public tree for quick testing. Perhaps ask Trond to keep
> it on his tree in a branch. (So to get some coverage under the linux-next
> tree mongers from Intel)
>

BTW: anyone tested how much this conflicts with dros's 17 patches?
     (Noticed how it is always 17 patches)
     If a brave sole can have both these merged on the same tree it
     would be easier for the testing.

Thanks
Boaz

