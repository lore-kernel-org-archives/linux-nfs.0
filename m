Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54629 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2HLSkX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Aug 2012 14:40:23 -0400
Message-ID: <5027F889.6090700@panasas.com>
Date: Sun, 12 Aug 2012 21:40:09 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH RFC 2/3] NFS41: send real write size in layoutget
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com> <1344391392-1948-3-git-send-email-bergwolf@gmail.com> <5027F63F.8070107@panasas.com>
In-Reply-To: <5027F63F.8070107@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/12/2012 09:30 PM, Boaz Harrosh wrote:

> So for objects the wasting factor is the actual i_size extending as a cause
> of layout_get, and not the number of pages served. So for us the gain is if
> client, that has a much newer information about i_size, sends it on first
> layout_get. Though extending file size only once on first layout_get and
> not on every layout_get.
> 


I want to clarify here. The i_size does not and must not grow as part of
a layout_get. Only a layout_commit might extend i_size.

the "file-size" I meant above is the current maximum size that can be
described by the inode's layout device-map. The device map does grow on
layout_get both for objects, as well as for example  a CEPH cluster. If we
send i_size from client then we only need extend device-map once during the
complete writeout. (If need extending)

Thanks
Boaz
