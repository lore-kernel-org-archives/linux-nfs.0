Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:65058 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755033Ab2IYMqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 08:46:50 -0400
Date: Tue, 25 Sep 2012 08:46:36 -0400
From: Jim Rees <rees@umich.edu>
To: "Peng, Tao" <tao.peng@emc.com>
Cc: Wei Yongjun <weiyj.lk@gmail.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix the return value of nfs4_blkdev_get()
Message-ID: <20120925124636.GA26766@umich.edu>
References: <CAPgLHd__m_A5gqBP1GgUJb=_fib7bOiJunVoNZn2HCiKyXVjrw@mail.gmail.com>
 <5DFC6BE3BA248842867E85C73BF94B050B18E564AB@MX41A.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5DFC6BE3BA248842867E85C73BF94B050B18E564AB@MX41A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peng, Tao wrote:

  > -----Original Message-----
  > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Wei
  > Yongjun
  > Sent: Tuesday, September 25, 2012 1:44 PM
  > To: Trond.Myklebust@netapp.com
  > Cc: yongjun_wei@trendmicro.com.cn; linux-nfs@vger.kernel.org
  > Subject: [PATCH] NFS: fix the return value of nfs4_blkdev_get()
  > 
  > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
  > 
  > In case of error, the function nfs4_blkdev_get() return NULL pointer.
  > But the user nfs4_blk_decode_device() check the return value by using
  > IS_ERR() and get error code from the return value. So we should better
  > change the return value of nfs4_blkdev_get() to return ERR_PTR().
  > 
  Yeah, it is merely mess and should be just removed...

It's leftover debug code. Get rid of it.
