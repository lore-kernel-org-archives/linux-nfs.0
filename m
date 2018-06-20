Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:40436 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbeFTQkn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2018 12:40:43 -0400
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet loss
To: Joe Perches <joe@perches.com>,
        'Trond Myklebust' <Trond.Myklebust@netapp.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>,
        'David Miller' <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, eric.dumazet@gmail.com,
        William.Allen.Simpson@gmail.com, gilad@codefidence.com,
        ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        'Neil Brown' <neilb@suse.de>,
        'Chuck Lever' <chuck.lever@oracle.com>,
        'Benny Halevy' <bhalevy@panasas.com>,
        'Alexandros Batsakis' <batsakis@netapp.com>,
        Andy Chittenden <andyc@bluearc.com>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
 <20100803.012144.267950450.davem@davemloft.net>
 <20100803021110.f0b3877b.akpm@linux-foundation.org>
 <4C57EE9A.7040308@gmail.com> <4c5ad0d6.42ecd80a.47d7.0dfc@mx.google.com>
 <1281037822.2948.49.camel@heimdal.trondhjem.org>
 <4c5bd64a.4a2ae30a.0283.0551@mx.google.com>
 <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com>
 <0dead6e0deabafe0abdd4b30f97bcdf5c12cd824.camel@perches.com>
From: Andy C <andyc.bluearc@gmail.com>
Message-ID: <bac42441-07c8-bb94-7559-94f9047654fa@gmail.com>
Date: Wed, 20 Jun 2018 17:40:40 +0100
MIME-Version: 1.0
In-Reply-To: <0dead6e0deabafe0abdd4b30f97bcdf5c12cd824.camel@perches.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-06-19 22:56, Joe Perches wrote:
> On Mon, 2010-08-09 at 10:27 +0100, Andy Chittenden wrote:
>
> You really need to check your clock.
> Mail sent in the year 2010?
>
I didn't send it just now. I sent it on 2010-08-09 at 10:27. And I did 
receive a copy at that time. If I'm reading the headers correctly, 
something happened here:

Received: from mchehab by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1fVNCq-0005da-3g; Tue, 19 Jun 2018 20:26:24 +0000
Received: from vger.kernel.org ([209.132.180.67])
	by bombadil.infradead.org with esmtp (Exim 4.72 #1 (Red Hat Linux))
	id 1OiOdm-0004za-Ks; Mon, 09 Aug 2010 09:27:30 +0000
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S1755981Ab0HIJ1U (ORCPT <rfc822;tgraf@infradead.org> + 8 others);
	Mon, 9 Aug 2010 05:27:20 -0400

-- 
Andy

