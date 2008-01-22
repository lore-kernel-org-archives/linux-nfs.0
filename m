From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Tue, 22 Jan 2008 12:52:53 -0500
Message-ID: <E4AF6F9C-A890-439C-9DD9-B0F6819FF7F2@oracle.com>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int> <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com> <1200938366.25562.14.camel@heimdal.trondhjem.org> <FD665904-E655-48E9-8508-D9E118762C84@oracle.com> <1200943495.25562.52.camel@heimdal.trondhjem.org> <1200948494.11003.71.camel@trinity.ogc.int> <1200955371.27963.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38131 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbYAVRyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2008 12:54:44 -0500
In-Reply-To: <1200955371.27963.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 21, 2008, at 5:42 PM, Trond Myklebust wrote:
> On Mon, 2008-01-21 at 14:48 -0600, Tom Tucker wrote:
>> modprobe my_favorite_transport
>>
>> mount .... -o proto="my_favorite_transport_id_string"
>>
>> and it works...
>>
>> Maybe I'm being naive, but that seems flexible and secure provided  
>> that
>> the transport layer code is not broken.
>
> You misunderstood me. I have no problems with passing the 'proto='  
> value
> down once it has been parsed. My concern is that people are assuming
> that we will allow these modules to have their own private mount
> parameters (i.e. private user interfaces).


To be clear, I'm referring only to passing the "proto=" value to  
xprt_create_transport.

For new and unsupported transport capabilities, I'm perfectly fine  
with having transport capability-specific options be supported as  
module parameters, or adding new mount options to the NFS mount  
option parser at a later time.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
