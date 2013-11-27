Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:25615 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab3K0QXD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 11:23:03 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] proc: change permission of /proc/self/mountstats to 0644
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131127154730.GA26985@infradead.org>
Date: Wed, 27 Nov 2013 11:22:35 -0500
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Message-Id: <3071D357-6AB9-45C5-902C-21CDAF3A904B@oracle.com>
References: <1385553135-23131-1-git-send-email-tigran.mkrtchyan@desy.de> <5069B68E-67AA-46C9-99C4-EE4839F71DFA@oracle.com> <20131127154730.GA26985@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 27, 2013, at 10:47 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Nov 27, 2013 at 10:21:29AM -0500, Chuck Lever wrote:
>> That is true only if there is a single mount namespace on your system.  The content of mountstats depends on each process's mount namespace.
>> 
>> However, I see that mounts and mountinfo, which also depend on a process's mount namespace, are all S_IRUGO.  I don't see a good reason mountstats should be different.
> 
> Could any of the counters be used as a covert channel?  Any leakage of
> information related to RPCSEC_GSS that could helper attackers?

Certainly not for the authentication-only pseudoflavor.

The numbers in this file are averages and approximate byte counts.  I'm hard-pressed to think of a way anything useful could be extracted.  But I'm not a security expert.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




