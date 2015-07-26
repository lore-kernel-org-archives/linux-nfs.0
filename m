Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35329 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbbGZKIO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 06:08:14 -0400
Received: by wibxm9 with SMTP id xm9so76372170wib.0
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2015 03:08:13 -0700 (PDT)
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B4B190.7070305@dev.mellanox.co.il>
Date: Sun, 26 Jul 2015 13:08:16 +0300
MIME-Version: 1.0
In-Reply-To: <20150724161848.25617.26092.stgit@build2.ogc.int>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/24/2015 7:18 PM, Steve Wise wrote:
> This is in preparation for adding new FRMR-only IO handlers
> for devices that support FRMR and not PI.

Steve,

I've given this some thought and I think we should avoid splitting
logic from PI and iWARP. The reason (other than code duplication) is
that currently the iser target support only up to 1MB IOs. I have some
code (not done yet) to support larger IOs by using multiple
registrations  per IO (with or without PI).
With a little tweaking I think we can get iwarp to fit in too...

So, do you mind if I take a crack at it?
