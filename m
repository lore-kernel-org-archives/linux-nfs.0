Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46477 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965321AbcAZP3n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 10:29:43 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [LSF/MM TOPIC] Remote access to pmem on storage targets
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5FD20017-B588-42E6-BBDA-2AA8ABDBA42B@ornl.gov>
Date: Tue, 26 Jan 2016 10:29:35 -0500
Cc: "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Message-Id: <D0C5C0B9-A1A2-4428-B3CA-7BBCC5BEF10D@oracle.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com> <5FD20017-B588-42E6-BBDA-2AA8ABDBA42B@ornl.gov>
To: "Atchley, Scott" <atchleyes@ornl.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 26, 2016, at 10:25 AM, Atchley, Scott <atchleyes@ornl.gov> wrote:
> 
>> On Jan 25, 2016, at 4:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> I'd like to propose a discussion of how to take advantage of
>> persistent memory in network-attached storage scenarios.
>> 
>> RDMA runs on high speed network fabrics and offloads data
>> transfer from host CPUs. Thus it is a good match to the
>> performance characteristics of persistent memory.
>> 
>> Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
>> fabrics. What kind of changes are needed in the Linux I/O
>> stack (in particular, storage targets) and in these storage
>> protocols to get the most benefit from ultra-low latency
>> storage?
>> 
>> There have been recent proposals about how storage protocols
>> and implementations might need to change (eg. Tom Talpey's
>> SNIA proposals for changing to a push data transfer model,
>> Sagi's proposal to utilize DAX under the NFS/RDMA server,
>> and my proposal for a new pNFS layout to drive RDMA data
>> transfer directly).
>> 
>> The outcome of the discussion would be to understand what
>> people are working on now and what is the desired
>> architectural approach in order to determine where storage
>> developers should be focused.
>> 
>> This could be either a BoF or a session during the main
>> tracks. There is sure to be a narrow segment of each
>> track's attendees that would have interest in this topic.
>> 
>> --
>> Chuck Lever
> 
> Chuck,
> 
> One difference on targets is that some NVM/persistent memory may be byte-addressable while other NVM is only block addressable.
> 
> Another difference is that NVMe-over-Fabrics will allow remote access of the target’s NVMe devices using the NVMe API.

As I understand it, NVMf devices look like local devices.
NVMf devices need globally unique naming to enable safe use
with pNFS and other remote storage access protocols.

--
Chuck Lever




