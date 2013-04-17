Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f175.google.com ([209.85.210.175]:47378 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965578Ab3DQRPN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Apr 2013 13:15:13 -0400
MIME-Version: 1.0
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
Date: Wed, 17 Apr 2013 10:15:13 -0700
Message-ID: <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Yan Burman <yanb@mellanox.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman <yanb@mellanox.com> wrote:
> Hi.
>
> I've been trying to do some benchmarks for NFS over RDMA and I seem to only get about half of the bandwidth that the HW can give me.
> My setup consists of 2 servers each with 16 cores, 32Gb of memory, and Mellanox ConnectX3 QDR card over PCI-e gen3.
> These servers are connected to a QDR IB switch. The backing storage on the server is tmpfs mounted with noatime.
> I am running kernel 3.5.7.
>
> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.

Remember there are always gaps between wire speed (that ib_send_bw
measures) and real world applications.

That being said, does your server use default export (sync) option ?
Export the share with "async" option can bring you closer to wire
speed. However, the practice (async) is generally not recommended in a
real production system - as it can cause data integrity issues, e.g.
you have more chances to lose data when the boxes crash.

-- Wendy
