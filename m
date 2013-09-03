Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27587 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760319Ab3ICSeD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 14:34:03 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v2 16/33] SUNRPC: Modify synopsis of rpc_client_register()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1378232595.6410.23.camel@leira.trondhjem.org>
Date: Tue, 3 Sep 2013 14:33:55 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Message-Id: <61E707DA-47D8-4415-BFFD-744F14CC9BF9@oracle.com>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net> <20130809165005.5362.34943.stgit@seurat.1015granger.net> <1378231471.6410.18.camel@leira.trondhjem.org> <6022E033-F121-48E1-860D-E163AF7A3CC3@oracle.com> <1378232595.6410.23.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2013, at 2:23 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-09-03 at 14:16 -0400, Chuck Lever wrote:
>> On Sep 3, 2013, at 2:04 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>> In particular note that the new code uses the rpc_clnt->cl_parent chain
>>> in order to implement sharing of the RPCSEC_GSS caches and pipe upcalls.
>> 
>> This might be a problem when swapping in a transport to a destination server, for example.
> 
> You're already swapping the cl_xprt and the cl_auth, why shouldn't you
> also swap the cl_parent in this situation?

Sounds reasonable.


>> How would you like to proceed with merging these?  Hold off until 3.13, take up to 15/33 now and the rest in 3.13, or take the whole series now and fix it up after the window closes?
> 
> I can take up to 15/33 now, but I'd like those warnings fixed. Can you
> throw in some 'fixup!' commits for the 2 issues that were pointed out?

Having up to 15/33 merged will be very helpful, thanks.  I'll work up fixes that apply on 15/33, and post them later today or tomorrow (depending on how fast the little legs of my build machine can run).


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




