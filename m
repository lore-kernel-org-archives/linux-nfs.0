Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:42422 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab2DXPkz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 11:40:55 -0400
Subject: Re: [PATCH] rpcbind: Only listen on requested hostnames for NC_TPI_COTS connections
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120424152950.GB13191@umich.edu>
Date: Tue, 24 Apr 2012 11:40:41 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2332F6F6-A1CF-4C0A-A35C-4E4EE588EC1D@oracle.com>
References: <1335194692-6714-1-git-send-email-ndevos@redhat.com> <82D8C43F-5C40-444C-9573-B4FF95F615DA@oracle.com> <4F957D30.9010102@redhat.com> <7C71F75F-3F15-401B-8700-38B0EBE2B595@oracle.com> <4F96C0E3.9090007@redhat.com> <20120424152950.GB13191@umich.edu>
To: Jim Rees <rees@umich.edu>, Niels de Vos <ndevos@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 24, 2012, at 11:29 AM, Jim Rees wrote:

> Niels de Vos wrote:
> 
>  On 04/23/2012 06:22 PM, Chuck Lever wrote:
>> 
>> So you did check the mail archive?  I seem to recall other patches like
>> this in the past, and that there is a reason why rpcbind works this way.
>> I simply don't remember the specifics right at the moment.
> 
>  I did, but no messages about this subject come up for me... Maybe I'm looking
>  in the wrong places :-/
> 
> I asked about this last November, and at that time Chuck referred me to the
> mail archive too.  I couldn't find any discussion either.  But the behavior
> is intentional, so I don't think you'll get a patch accepted.

Going back to the rpcbind(8) man page, the "-h" is meant to work around a brokenness of RPC over UDP.  UDP replies can come from any server address, as I mentioned before, and most Linux clients, at least, don't like an RPC reply to come from a different address than the request was sent to.

We don't need or want this option for connection-oriented transports.  The reply will always be returned on the same connection that request was made on.

Restricting the bind address for rpcbind's listener is a different, and perhaps orthogonal, issue.  In addition to trimming rpcbind's listener address space via IP tables, you can also run the rpcbind server, and the RPC services it shepherds, in a separate network namespace.

> I never did
> discover the reason but I do have a workaround.  I just don't run rpcbind.
> 
> This was the most informative response I got:
> 
> Date: Tue, 8 Nov 2011 19:01:51 +1100
> From: Max Matveev <makc@redhat.com>
> Subject: Re: rpcbind -h
> To: Jim Rees <rees@umich.edu>
> Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
> 
> Chuck's quote from the manpage reminded me - -h was used to work            
> around the address selection: if server has more then one address the       
> reply may use any of them. Some clients don't like it.
> 
> This issue should go away after
> 
> commit 74ef3df0236c55185225c62fba34953f2582da72
> Author: Olaf Kirch <okir@suse.de>      
> Date:   Wed Mar 2 10:09:24 2011 -0500
> 
> was added to libtirpc.
> 
> rees> As I said before, I was hoping for the equivalent of "portmap
> rees> -l".  I was ready to code up a patch of some kind but now have
> rees> a workaround (mount with nolock and don't run rpcbind at all).
> 
> iptables is another option.
> 
> max
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




