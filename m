Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0233.hostedemail.com ([216.40.44.233]:33661 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S935772AbeFSWDT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2018 18:03:19 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave07.hostedemail.com (Postfix) with ESMTP id B27E918044B59
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2018 21:56:12 +0000 (UTC)
Message-ID: <0dead6e0deabafe0abdd4b30f97bcdf5c12cd824.camel@perches.com>
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet loss
From: Joe Perches <joe@perches.com>
To: Andy Chittenden <andyc.bluearc@gmail.com>,
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
Date: Tue, 19 Jun 2018 14:56:05 -0700
In-Reply-To: <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
         <20100803.012144.267950450.davem@davemloft.net>
         <20100803021110.f0b3877b.akpm@linux-foundation.org>
         <4C57EE9A.7040308@gmail.com>  <4c5ad0d6.42ecd80a.47d7.0dfc@mx.google.com>
         <1281037822.2948.49.camel@heimdal.trondhjem.org>
         <4c5bd64a.4a2ae30a.0283.0551@mx.google.com>
         <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-08-09 at 10:27 +0100, Andy Chittenden wrote:

You really need to check your clock.
Mail sent in the year 2010?

