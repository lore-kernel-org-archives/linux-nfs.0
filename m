From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Mon, 6 Jul 2009 14:32:41 -0400
Message-ID: <9D0F8CF2-3FA2-4065-A125-DE02C2674129@oracle.com>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com> <18992.35996.986951.556723@notabene.brown> <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com> <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com> <4A51F125.5080709@suse.de> <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com> <4A52217E.9050207@suse.de> <4E8F91E6-4E55-44BB-889B-DDB9910129BF@oracle.com> <1246898450.11267.12.camel@heimdal.trondhjem.org> <68129579-E484-4E7E-B38D-4E14ED5A5B1D@oracle.com> <1246900456.11267.34.camel@heimdal.trondhjem.org> <71D4E90D-471B-4BFA-B47C-6A5BFD0754E9@oracle.com> <1246903105.23966.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56703 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZGFScs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2009 14:32:48 -0400
In-Reply-To: <1246903105.23966.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 6, 2009, at 1:58 PM, Trond Myklebust wrote:
> On Mon, 2009-07-06 at 13:51 -0400, Chuck Lever wrote:
>> In both cases, it turns out that the library implementations in user
>> space already fail quickly.  RPC_CANTRECV is returned if an attempt  
>> is
>> made to send an rpcbind query to an inactive UDP port.
>> RPC_SYSTEMERROR/ECONNREFUSED is returned if an attempt is made to  
>> send
>> an rpcbind query to an inactive TCP port.  In my view, the kernel is
>> lacking here, and should be made to emulate user space more closely.
>
> I fully agree that we can fix the above by more judicious  
> interpretation
> of the returned networking errors. What I don't see eye to eye with is
> the assertion that has been floating about that the current behaviour
> should be a good enough reason to add kernel AF_LOCAL support.

Since portmapper doesn't support it, and the kernel (for now) needs  
backwards compatibility with portmapper, AF_LOCAL for rpcbind is  
rather a non-starter.

In my opinion there are other reasons to consider kernel-level  
AF_LOCAL support at some later point.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
