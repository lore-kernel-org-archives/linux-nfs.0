Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757476Ab0IBWE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 18:04:26 -0400
Message-ID: <4C801F67.50604@RedHat.com>
Date: Thu, 02 Sep 2010 18:04:23 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount: RDMA processing in the mount command is broken
References: <1283457651-12010-1-git-send-email-steved@redhat.com> <E401A220-AAD8-42F1-AE81-3B1EEF209428@oracle.com>
In-Reply-To: <E401A220-AAD8-42F1-AE81-3B1EEF209428@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/02/2010 04:35 PM, Chuck Lever wrote:
> 
> On Sep 2, 2010, at 4:00 PM, Steve Dickson wrote:
> 
>> The mounting code that process RMDA mounts is broken in a few places
>>
>> First with '-o proto=rdma' was broken because nfs_get_proto()
>> did not how to convert a netid of 'rdma' in to a AF_INET
>> address family.
>>
>> Secondly, '-o rdma' was broken because po_get() was being using
>> to detect the existence of 'rdma' in the options. With '-o rdma'
>> there is no value associated with that option so po_get()
>> was always return NULL.
> 
> Looking at nfs(5), "rdma" as a stand-alone option isn't documented.  Only "proto=rdma" appears to be mentioned.  Thus I would argue that this is already behaving correctly.
> 
> Are you proposing to add support for "-o rdma" ?  If so what would that mean?
See Documentation/filesystems/nfs/nfs-rdma.txt

I see no problem in handing this same why we handle 'udp' and 'tcp'

steved.
