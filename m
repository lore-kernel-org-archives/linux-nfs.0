Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217Ab0IBWqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 18:46:15 -0400
Message-ID: <4C802914.50505@RedHat.com>
Date: Thu, 02 Sep 2010 18:45:40 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount: RDMA processing in the mount command is broken
References: <1283457651-12010-1-git-send-email-steved@redhat.com> <1FB4635E-5757-420B-A32B-47D2D1778A56@oracle.com>
In-Reply-To: <1FB4635E-5757-420B-A32B-47D2D1778A56@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Chuck,

On 09/02/2010 04:15 PM, Chuck Lever wrote:
> 
> On Sep 2, 2010, at 4:00 PM, Steve Dickson wrote:
> 
>> The mounting code that process RMDA mounts is broken in a few places
>>
>> First with '-o proto=rdma' was broken because nfs_get_proto()
>> did not how to convert a netid of 'rdma' in to a AF_INET
>> address family.
> 
> The usual solution for that is to add appropriate definitions to /etc/netconfig.  
> Since "rdma" is going to become (or has become) a valid "IETF standard" netid, 
> shouldn't this be handled just like the other netids?  
No.. because it is not a netid... when 'rdma' become a netid we'll treat 
like one. Until the then let treat like we always have been... 

> At some point "rdma" is going to start showing up in rpcbind, 
> so this is going to have to work like a normal netid.
When this happen I will be more that willing to accept 
the patches that will add support for the new netid.

> 
>> Secondly, '-o rdma' was broken because po_get() was being using
>> to detect the existence of 'rdma' in the options. With '-o rdma'
>> there is no value associated with that option so po_get()
>> was always return NULL.
> 
> This should be handled just the same way the "udp" and "tcp" mount 
> options are handled, in nfs_nfs_protocol().  Just add an entry for 
> "rdma" in nfs_transport_opttbl. The problem is we don't have an 
> IPPROTO_ number for RDMA, so you'll have to make one up.
Exactly... And I was not about to make up a  IPPROTO_ number
I just think that's crazy... Plus it turns out we didn't need to.
All that's needed is for the address family to be set to 
AF_INET, from what Tom said. So it makes total sense put the
check in nfs_get_proto()

> What does the kernel do in these cases?
I took a quick look it appears they use IPPROTO_TCP (see xprt_setup_rdma())
but it appears they did not make up a IPPROTO_ number.

> 
>> This patch address both those problems.
> 
> Let's not riddle the mount code with these ad hoc string comparisons when 
> we've already got plenty adequate generic support for adding new transport labels.
Riddle?? I'm condensing two existing (broken) if statements and adding 
a third... I'm a bit taken back by your verbiage... I see changes to be
very unobtrusive and clean... with the befit of them working... ;-)

steved.

