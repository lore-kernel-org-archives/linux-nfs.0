Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:56920 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab1DGOgq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 10:36:46 -0400
Subject: Re: Prioritizing readdirplus/getattr/lookup
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <642211.9524.qm@web65416.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 10:36:34 -0400
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
Message-Id: <CCB59DB2-C865-4C36-BB77-1A76E6B261E9@oracle.com>
References: <642211.9524.qm@web65416.mail.ac4.yahoo.com>
To: Andrew Klaassen <clawsoon@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 7, 2011, at 10:34 AM, Andrew Klaassen wrote:

> --- On Thu, 4/7/11, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> On Apr 6, 2011, at 3:25 PM, Andrew Klaassen wrote:
>> 
>>> I have, for now, hacked my way around my problem by
>>> splitting the server's uplink into two separate bonds. 
>>> This seems to have moderated the transaction rate of the HPC
>>> farm and allowed the "ls -l" calls to be served at an
>>> acceptable rate.
>> 
>> Have you created enough nfsd threads on your Linux NFS
>> servers?
> 
> That was one of the things I varied as part of my testing; almost every power of 2 from 8 threads up to 1024 threads.  It actually made things slightly worse, not better, but I can certainly give it a try again.

Is the server an SMP system?  Do you see high CPU load during times of slow performance?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




