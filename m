From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting a server.
Date: Sun, 22 Feb 2009 15:29:44 -0500
Message-ID: <7DBDEC87-CB31-404E-8C4D-2762358387DE@oracle.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com> <499FB08B.1070200@candelatech.com> <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com> <49A0E802.9000209@candelatech.com> <1235329791.7331.75.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26230 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbZBVUaF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 15:30:05 -0500
In-Reply-To: <1235329791.7331.75.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 22, 2009, at Feb 22, 2009, 2:09 PM, Trond Myklebust wrote:
> I really dislike this idea of adding routing information at the sunrpc
> level.

Well I think we have had problems in the past where RPC replies on  
multi-homed systems go to the wrong interface and are dropped.  Isn't  
that why we now have the source address field in rpc_create_args?  I  
suspect we might have similar problems with NSM, for instance.

It is also the case that rpcbind v3 and v4 allow an RPC service to  
register a bind address that is not ANYADDR.  That's what universal  
addresses are for.

So by itself I don't find this feature request terribly objectionable,  
and I think it's worth some discussion.

> So, I repeat: what is the application for all this? I've heard
> mutterings about routing and multi-homed servers, but absolutely  
> zero in
> the way of specific applications and requirements.

I concur that we should get more information about what is at issue.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
