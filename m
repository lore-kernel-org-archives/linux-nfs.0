Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:62689 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935712Ab3DRQQW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 12:16:22 -0400
MIME-Version: 1.0
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
	<CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
	<62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
	<CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
Date: Thu, 18 Apr 2013 09:16:22 -0700
Message-ID: <CABgxfbFo0LhCRupOa+z+bLmb5AjmS_aqpLtsPCYBNJ79wm1BXw@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Yan Burman <yanb@mellanox.com>
Cc: "Atchley, Scott" <atchleyes@ornl.gov>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 18, 2013 at 5:47 AM, Yan Burman <yanb@mellanox.com> wrote:
>
>
> What do you suggest for benchmarking NFS?
>

I believe SPECsfs has been widely used by NFS (server) vendors to
position their product lines. Its workload was based on a real life
NFS deployment. I think it is more torward office type of workload
(large client/user count with smaller file sizes e.g. software
development with build, compile, etc).

BTW, we're experimenting a similar project and would be interested to
know your findings.

-- Wendy
