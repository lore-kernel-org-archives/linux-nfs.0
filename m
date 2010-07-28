Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:48564 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752886Ab0G1JpT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 05:45:19 -0400
Message-ID: <4C4FFC2B.4020906@Voltaire.com>
Date: Wed, 28 Jul 2010 12:45:15 +0300
From: Or Gerlitz <ogerlitz@Voltaire.com>
To: Sebastien Godard <sysstat@orange.fr>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: iostat "await" like counter for measuring nfs latency
References: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com> <1280244478.2981.3.camel@heimdal.trondhjem.org>
In-Reply-To: <1280244478.2981.3.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Tue, 2010-07-27 at 13:07 +0300, Or Gerlitz wrote:
>> Doing some iscsi and nfs performance testing, I realized that iostat(1)
>> doesn't support an "await" like counter for measuring nfs latency.
>> Can tracking nfs latency be done in other means? is there a plan to
>> extend the nfs iostats code to include such/similar counter?

> The information is already available in /proc/self/mountstats. It is up
> to iostat to start using it.

Sebastian, is there a plan to support await like counter in sysstat? 

I didn't find a source repository (is there an open one? where?) so 
downloaded the latest code (version 9.1.3) drop from the website and 
couldn't see there such a counter, am I missing something?

Or.


