Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50979 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab1DEU5w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 16:57:52 -0400
Message-ID: <4D9B8247.9050300@panasas.com>
Date: Tue, 05 Apr 2011 13:57:43 -0700
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Jim Rees <rees@umich.edu>, Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com>	 <882887.75491.qm@web65412.mail.ac4.yahoo.com>	 <20110404230528.GA2624@merit.edu> <4D9A61C9.1030900@panasas.com>	 <20110405003944.GA31014@merit.edu> <4D9B195E.60108@panasas.com>	 <640DA909-32A8-43EF-AF0B-ACE0689AC0CD@cs.cmu.edu>	 <4D9B694D.1030609@panasas.com>	 <1302032887.7265.40.camel@lade.trondhjem.org>	 <4D9B7304.7010506@panasas.com> <1302033466.7265.45.camel@lade.trondhjem.org>
In-Reply-To: <1302033466.7265.45.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-05 12:57, Trond Myklebust wrote:
> On Tue, 2011-04-05 at 12:52 -0700, Benny Halevy wrote:
>> On 2011-04-05 12:48, Trond Myklebust wrote:
>>> On Tue, 2011-04-05 at 12:11 -0700, Benny Halevy wrote:
>>>> On 2011-04-05 10:14, Garth Gibson wrote:
>>>>> The OpenGroup HECE proposals for extending the application/filesystem interface did not have a team of implementers behind them.  At the time some of the parallel file system vendors that added modules to the kernel were willing to work toward supporting these interfaces, but not a broader community.   
>>>>>
>>>>> I encourage the pNFS community to consider the use cases that led to those proposals.
>>>>>
>>>>> One example is lazy attributes.  Folks running large parallel jobs have a nasty habit of monitoring the progress of the job by running on their desktop a looping script doing ls -l on output files.  What is the length of a file that is open and being written to by other nodes?  Much of the time you want to be able to ask for a recently accurate value of attributes without recalling layouts, but perhaps some of the time you would like layouts to be recalled, or at least committed.
>>>>
>>>> Right now the pNFS server does not have to recall the layout on GETATTR
>>>> so lazy would be the default behavior for most implementations. Even if
>>>> a client holds a delegation the server could send a CB_GETATTR to it to
>>>> get the latest attributes without recalling the layout.  At any rate,
>>>> the broader issue is that the posix system call API assumes a local file
>>>> system and is not network not cluster file-system aware.
>>>
>>> Recalling the outstanding layouts in a directory on every 'ls -l' sounds
>>> like the perfect recipe for poor performance. I can't see why any
>>> servers would want to do this.
>>>
>>> In any case, a layout recall does not trigger client writeback: layouts
>>> do not define a caching protocol.
>>
>> Yet for already written (DATA_SYNC) data, a layout recall should trigger
>> a LAYOUTCOMMIT and that will update the visible attrs.
> 
> Sure, but if the client still has the file open and has not flushed its
> writes, then you are proposing a very expensive way to update attributes
> that may bear no relevance to the true state of the file.
> 
> pNFS will suck _badly_ if you start recalling layouts willy nilly.

Agreed.  Supporting CB_GETATTR seems to be a better choice.

Benny
