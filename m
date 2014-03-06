Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:62129 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbaCFQQc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 11:16:32 -0500
Received: by mail-ie0-f179.google.com with SMTP id lx4so2840763iec.24
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 08:16:32 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <473B4660-0C59-49D4-8BBD-24ABD929AFB9@oracle.com>
Date: Thu, 6 Mar 2014 11:16:30 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BB585E65-78D2-45D9-9513-BB988686F1A9@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306123438.GA21799@umich.edu> <04BE61B0-08B5-4E0C-88B6-6D93127BB64E@oracle.com> <5B1102FE-8521-4BEF-8A2B-CE17EC32777F@primarydata.com> <17607EE5-614A-4B13-B5E7-0D1344A30C7F@oracle.com> <2A4F9722-1ED1-462E-B66B-669217957814@primarydata.com> <473B4660-0C59-49D4-8BBD-24ABD929AFB9@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 11:13, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Mar 6, 2014, at 11:02 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Mar 6, 2014, at 10:59, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Mar 6, 2014, at 10:33 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>> 
>>>> 
>>>> On Mar 6, 2014, at 10:26, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>>> 
>>>>> On Mar 6, 2014, at 7:34 AM, Jim Rees <rees@umich.edu> wrote:
>>>>> 
>>>>>> Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
>>>>>> and not try to write anything to nfs.
>>>>> 
>>>>> I agree. A static web page workload should be read-mostly or read-only. The (small) corruption risk with “ro,soft" is that an interrupted read would cause the client to cache incomplete data.
>>>> 
>>>> What? How? If that were the case, we would have a blatant read bug. As I read the current code, _any_ error will cause the page to not be marked as up to date.
>>> 
>>> Agree, the design is sound. But we don’t test this use case very much, so I don’t have 100% confidence that there are no bugs.
>> 
>> Is that the royal ‘we’, or are you talking on behalf of all the QA departments and testers here? I call bullshit…
> 
> If you want to differ with my opinion, fine. But your tone is not professional or appropriate for a public forum. You need to start treating all of your colleagues with respect, including me.
> 
> If anyone else had claimed a testing gap, you would have said “If that were the case, we would have a blatant read bug” and left it at that. But you had to go one needless and provocative step further.
> 
> Stop bullying me, Trond. I’ve had enough of it.

The stop spreading FUD. That is far from professional too...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

