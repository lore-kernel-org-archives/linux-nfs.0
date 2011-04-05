Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:51051 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab1DETLN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 15:11:13 -0400
Received: by pxi2 with SMTP id 2so396808pxi.10
        for <linux-nfs@vger.kernel.org>; Tue, 05 Apr 2011 12:11:12 -0700 (PDT)
Message-ID: <4D9B694D.1030609@panasas.com>
Date: Tue, 05 Apr 2011 12:11:09 -0700
From: Benny Halevy <bhalevy@panasas.com>
To: Garth Gibson <garth@cs.cmu.edu>
CC: linux-nfs@vger.kernel.org, Jim Rees <rees@umich.edu>,
        Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com> <882887.75491.qm@web65412.mail.ac4.yahoo.com> <20110404230528.GA2624@merit.edu> <4D9A61C9.1030900@panasas.com> <20110405003944.GA31014@merit.edu> <4D9B195E.60108@panasas.com> <640DA909-32A8-43EF-AF0B-ACE0689AC0CD@cs.cmu.edu>
In-Reply-To: <640DA909-32A8-43EF-AF0B-ACE0689AC0CD@cs.cmu.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-05 10:14, Garth Gibson wrote:
> The OpenGroup HECE proposals for extending the application/filesystem interface did not have a team of implementers behind them.  At the time some of the parallel file system vendors that added modules to the kernel were willing to work toward supporting these interfaces, but not a broader community.   
>
> I encourage the pNFS community to consider the use cases that led to those proposals.
>
> One example is lazy attributes.  Folks running large parallel jobs have a nasty habit of monitoring the progress of the job by running on their desktop a looping script doing ls -l on output files.  What is the length of a file that is open and being written to by other nodes?  Much of the time you want to be able to ask for a recently accurate value of attributes without recalling layouts, but perhaps some of the time you would like layouts to be recalled, or at least committed.

Right now the pNFS server does not have to recall the layout on GETATTR
so lazy would be the default behavior for most implementations. Even if
a client holds a delegation the server could send a CB_GETATTR to it to
get the latest attributes without recalling the layout.  At any rate,
the broader issue is that the posix system call API assumes a local file
system and is not network not cluster file-system aware.

Benny

> garth
>
> On Apr 5, 2011, at 9:30 AM, Benny Halevy wrote:
>> On 2011-04-04 17:39, Jim Rees wrote:
>>> Benny Halevy wrote:
>>>
>>>  Like this? :)
>>>  http://www.opengroup.org/platform/hecewg/uploads/40/10903/posix_io_readdir+.pdf
>>>
>>> Yes, exactly, but that never went anywhere, did it?
>> Correct.  It did not go anywhere AFAIK.
>>
>> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

