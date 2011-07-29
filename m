Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:60746
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752313Ab1G2SpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 14:45:00 -0400
Date: Fri, 29 Jul 2011 14:44:55 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <bergwolf@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jim Rees <rees@umich.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110729184455.GA30678@infradead.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
 <CA+a=Yy78jFNm+fqmX9FeK5MivT4A3homrV2=ZQLHgzusZZ0x+Q@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+a=Yy78jFNm+fqmX9FeK5MivT4A3homrV2=ZQLHgzusZZ0x+Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 30, 2011 at 01:45:29AM +0800, Peng Tao wrote:
> After fixing common.rc, "./check -nfs" can run but failed and stopped
> at case 088. Both pnfs block and NFSv4 failed at the same case. Did
> anyone run xfstests over NFSv4 before? I'm wondering whether it is a
> regression or if case 088 is valid for NFSv4.

I've only tested it on NFSv3, and can't remember 088 failing.

