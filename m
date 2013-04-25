Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45136 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115Ab3DYV6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 17:58:48 -0400
MIME-Version: 1.0
In-Reply-To: <51799D52.1040903@opengridcomputing.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
	<CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
	<62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
	<CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
	<20130423210607.GJ3676@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
	<20130424150540.GB20275@fieldses.org>
	<20130424152631.GC20275@fieldses.org>
	<CABgxfbHShU7aEttJ35vdAjXduPFFj8+E4=5LZqOgh4e=5bax5Q@mail.gmail.com>
	<CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com>
	<517823E0.4000402@talpey.com>
	<CABgxfbHePAyq6AH9TFKZKUmwEHOupuYUnfc1W99HAuDkYddUqQ@mail.gmail.com>
	<51798C51.50209@talpey.com>
	<51799D52.1040903@opengridcomputing.com>
Date: Thu, 25 Apr 2013 14:58:48 -0700
Message-ID: <CABgxfbHnqQyucEpbGhsQ8-pA69peHUza7L7WHKD1K1n9Zv0WXQ@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Yan Burman <yanb@mellanox.com>, "Atchley, Scott" <atchleyes@ornl.gov>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 25, 2013 at 2:17 PM, Tom Tucker <tom@opengridcomputing.com> wrote:
> The Mellanox driver uses red-black trees extensively for resource
> management, e.g. QP ID, CQ ID, etc... When completions come in from the HW,
> these are used to find the associated software data structures I believe. It
> is certainly possible that these trees get hot on lookup when we're pushing
> a lot of data. I'm surprised, however, to see rb_insert_color there because
> I'm not aware of any where that resources are being inserted into and/or
> removed from a red-black tree in the data path.
>

I think they (rb calls) are from base kernel, not from any NFS and/or
IB module (e.g. RPC, MLX, etc). See the right column ? .... it says
"/root/vmlinux". Just a guess - I don't know much about this "perf"
command.

 -- Wendy
