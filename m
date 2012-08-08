Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:59805 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759217Ab2HHUMW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 16:12:22 -0400
Message-ID: <5022C824.504@parallels.com>
Date: Thu, 9 Aug 2012 00:12:20 +0400
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
> Stanislav, what's left to be done to get per-container unix sockets?

Honestly, I haven't even started this task.
But if it's up to me, I'll try to measureit's complexity tomorrow.
The task itself doesn't look too complex at first sight.
But anyway it's inclusion depends also on network developers comunity 
resolution.

>
> --b.

