Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40319 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab0ITUhq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 16:37:46 -0400
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100920195635.GA18808@fieldses.org>
Date: Mon, 20 Sep 2010 16:35:54 -0400
Cc: Pavel Emelyanov <xemul@parallels.com>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <14F506C2-8BDB-440E-A5A9-A99E4CC7512D@oracle.com>
References: <4C90BADB.10700@parallels.com> <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com> <20100920180418.GN4580@fieldses.org> <4C97B248.1030801@parallels.com> <EE0DC983-8CFA-42FA-8D64-F4E2564E6FB0@oracle.com> <20100920195635.GA18808@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2010, at 3:56 PM, J. Bruce Fields wrote:

> On Mon, Sep 20, 2010 at 03:28:00PM -0400, Chuck Lever wrote:
>> 
>> On Sep 20, 2010, at 3:13 PM, Pavel Emelyanov wrote:
>>> The nearest plan is
>>> 
>>> 1. Prepare the sunrpc layer to work in net namespaces 2. Make
>>> rpcpipefs and nfsd filesystems be mountable multiple times 3. Make
>>> support for multiple instances of the nfsd caches 4. Make suuport
>>> for multiple instances of the nfsd_serv
>>> 
>>> After this several NFSd-s can be used in containers (hopefully I
>>> didn't miss anything).
>> 
>> Are you assuming NFSv4 only?  Something needs to be done about NLM and
>> NSM to make this work right.
>> 
>> Is there an issue for idmapper and svcgssd?  Probably not, but worth
>> exploring.
>> 
>> And, how about AUTH_SYS certs?  These contain the host's name in them,
>> and that depends on the net namespace.  NLM uses AUTH_SYS, and I
>> believe the NFS server can make NLM calls to the client.
> 
> The client probably can't use the auth_sys cred on nlm callbacks in any
> sensible way, so this may not be a big deal.

I doubt anything looks at that hostname, really.  My worry is that it could leak information (like the wrong hostname) onto the network.

-- 
chuck[dot]lever[at]oracle[dot]com




