Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:53285
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905Ab1HKGGm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 02:06:42 -0400
Date: Thu, 11 Aug 2011 02:06:33 -0400
From: Christoph Hellwig <hch@infradead.org>
To: tao.peng@emc.com
Cc: torvalds@linux-foundation.org, rdunlap@xenotime.net, bergwolf@gmail.com,
        Trond.Myklebust@netapp.com, linux-raid@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
Message-ID: <20110811060633.GA11654@infradead.org>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
 <20110810122304.96b8be67.rdunlap@xenotime.net>
 <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
 <20110810175829.a834d80f.rdunlap@xenotime.net>
 <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com>
 <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Note that the object layout also effectively needs the block layer.

