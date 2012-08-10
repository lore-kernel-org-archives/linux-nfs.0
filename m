Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44644 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2HJNHK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 09:07:10 -0400
Message-ID: <50250776.6010609@parallels.com>
Date: Fri, 10 Aug 2012 17:07:02 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism for
 nfsd
References: <1341958332.17428.12.camel@lade.trondhjem.org> <1341959112.17428.19.camel@lade.trondhjem.org> <20120710223818.GA6720@fieldses.org> <1341961118.17428.29.camel@lade.trondhjem.org> <20120711170331.GE11432@fieldses.org> <20120711172714.GA13610@fieldses.org> <1342028948.25375.45.camel@lade.trondhjem.org> <20120712221058.GC24162@fieldses.org> <20120713154302.GA32660@fieldses.org> <20120808193659.GA942@fieldses.org> <20120808194359.GB942@fieldses.org>
In-Reply-To: <20120808194359.GB942@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

08.08.2012 23:43, J. Bruce Fields пишет:
> On Wed, Aug 08, 2012 at 03:36:59PM -0400, J. Bruce Fields wrote:
>> However, one hangup: figuring out how to switch on gssproxy
>> per-container isn't very interesting until gssproxy can actually work
>> per-container.  I'd *really* like to get the unix socket stuff worked
>> out first.
>
> Stanislav, what's left to be done to get per-container unix sockets?
>

I've sent patches for review:
"net: connect to UNIX sockets from specified root"

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
