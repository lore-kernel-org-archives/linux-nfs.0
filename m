Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41313 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab1DEROt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 13:14:49 -0400
Subject: Re: Prioritizing readdirplus/getattr/lookup
Content-Type: text/plain; charset=us-ascii
From: Garth Gibson <garth@cs.cmu.edu>
In-Reply-To: <4D9B195E.60108@panasas.com>
Date: Tue, 5 Apr 2011 13:14:43 -0400
Cc: Garth Gibson <garth@cs.cmu.edu>, Jim Rees <rees@umich.edu>,
        Andrew Klaassen <clawsoon@yahoo.com>,
        Benny Halevy <bhalevy@panasas.com>
Message-Id: <640DA909-32A8-43EF-AF0B-ACE0689AC0CD@cs.cmu.edu>
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com> <882887.75491.qm@web65412.mail.ac4.yahoo.com> <20110404230528.GA2624@merit.edu> <4D9A61C9.1030900@panasas.com> <20110405003944.GA31014@merit.edu> <4D9B195E.60108@panasas.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The OpenGroup HECE proposals for extending the application/filesystem interface did not have a team of implementers behind them.  At the time some of the parallel file system vendors that added modules to the kernel were willing to work toward supporting these interfaces, but not a broader community.   

I encourage the pNFS community to consider the use cases that led to those proposals.

One example is lazy attributes.  Folks running large parallel jobs have a nasty habit of monitoring the progress of the job by running on their desktop a looping script doing ls -l on output files.  What is the length of a file that is open and being written to by other nodes?  Much of the time you want to be able to ask for a recently accurate value of attributes without recalling layouts, but perhaps some of the time you would like layouts to be recalled, or at least committed.

garth

On Apr 5, 2011, at 9:30 AM, Benny Halevy wrote:
> On 2011-04-04 17:39, Jim Rees wrote:
>> Benny Halevy wrote:
>> 
>>  Like this? :)
>>  http://www.opengroup.org/platform/hecewg/uploads/40/10903/posix_io_readdir+.pdf
>> 
>> Yes, exactly, but that never went anywhere, did it?
> 
> Correct.  It did not go anywhere AFAIK.
> 
> Benny

