Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailuogwhop.emc.com ([168.159.213.141]:45948 "EHLO
	mailuogwhop.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbaHGQTL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 12:19:11 -0400
From: "faibish, sorin" <faibish_sorin@emc.com>
To: Christoph Hellwig <hch@lst.de>
CC: Peng Tao <bergwolf@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Date: Thu, 7 Aug 2014 12:18:41 -0400
Subject: RE: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger
	than page size
Message-ID: <2512424DBC01FD48843E938C780FA97C1D160F930B@MX23A.corp.emc.com>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
 <1407396229-4785-9-git-send-email-hch@lst.de>
 <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
 <20140807112537.GA3437@lst.de>
 <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
 <2512424DBC01FD48843E938C780FA97C1D160F928F@MX23A.corp.emc.com>
 <20140807161049.GA22527@lst.de>
In-Reply-To: <20140807161049.GA22527@lst.de>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

What Peng suggested to solve: "marking it writeback before unlocking in bl_find_get_zeroing_page()?"

-----Original Message-----
From: Christoph Hellwig [mailto:hch@lst.de] 
Sent: Thursday, August 07, 2014 12:11 PM
To: faibish, sorin
Cc: Peng Tao; Trond Myklebust; linuxnfs
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than page size

On Thu, Aug 07, 2014 at 08:56:04AM -0400, faibish, sorin wrote:
> Why don't you send a patch?

What patch?  Rewriting the broken code that was put in to support a server I don't have access to and that apparently no one cared enough before to fix even the most trivial bugs for?

I can leave the code for it in, but I can neither test nor really support it, and from the state of the code it doesn't seem like anyone else really cares for it.

How will sign up for supporting and testing > PAGE_SIZE servers if we leave that support in?  And with support I mean regular runs of basic QA like xfstests or just doing a simple dd if=/dev/zero of=/mnt/nfs/bigfile, which already causes softlocks with the current code.
