Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47727 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab1DETqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 15:46:14 -0400
Message-ID: <4D9B7183.7000301@panasas.com>
Date: Tue, 05 Apr 2011 12:46:11 -0700
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com> <882887.75491.qm@web65412.mail.ac4.yahoo.com> <20110404230528.GA2624@merit.edu> <4D9A61C9.1030900@panasas.com> <20110405003944.GA31014@merit.edu> <4D9B195E.60108@panasas.com> <640DA909-32A8-43EF-AF0B-ACE0689AC0CD@cs.cmu.edu> <4D9B694D.1030609@panasas.com> <20110405193425.GA4263@merit.edu>
In-Reply-To: <20110405193425.GA4263@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-05 12:34, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   At any rate, the broader issue is that the posix system call API assumes a
>   local file system and is not network not cluster file-system aware.
> 
> It would be interesting to see someone who is affected by this implement the
> readdirplus system call, modify ls to use it, and report the results.  I
> suspect the system call won't go anywhere in linux without some evidence
> that it solves a real problem for real users.

How hard would it be to implement a micro-benchmark with pynfs to
compare performance of readdir + stats vs. readdirplus as a first cut
estimate of the benefits?

Benny

