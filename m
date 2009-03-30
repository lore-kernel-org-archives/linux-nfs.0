From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 03/47] nfsd: add a struct nfsd4_slot pointer to	struct
 nfsd4_compound_state
Date: Mon, 30 Mar 2009 22:59:55 +0300
Message-ID: <49D124BB.8080909@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229057-7887-1-git-send-email-bhalevy@panasas.com> <20090329204656.GB18661@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27867 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760261AbZC3UAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 16:00:00 -0400
In-Reply-To: <20090329204656.GB18661@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 23:46 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Sat, Mar 28, 2009 at 11:30:57AM +0300, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> To be used for sessions DRC replay.
> 
> It'd be more helpful to have this combined with whatever patch first
> defines and/or uses nfsd4_slot.

Agreed.  I'll move it there.

Benny

> 
> --b.
