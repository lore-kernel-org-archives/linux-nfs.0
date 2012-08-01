Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361Ab2HAMjL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 08:39:11 -0400
Message-ID: <50192365.7090402@RedHat.com>
Date: Wed, 01 Aug 2012 08:39:01 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NFS: Fix a number of bugs in the idmapper
References: <1343746117.5528.3.camel@lade.trondhjem.org> <20120731144234.6664.85664.stgit@warthog.procyon.org.uk> <6978.1343746575@warthog.procyon.org.uk> <1343747261.5528.10.camel@lade.trondhjem.org> <20120731163708.GE27834@fieldses.org> <20120731171121.GF27834@fieldses.org>
In-Reply-To: <20120731171121.GF27834@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 01:11 PM, J. Bruce Fields wrote:
> On Tue, Jul 31, 2012 at 12:37:08PM -0400, bfields wrote:
>> On Tue, Jul 31, 2012 at 03:07:42PM +0000, Myklebust, Trond wrote:
>>> We don't expect people to be running both types of idmapper at the same
>>> time. Normally, the distribution will set up one or the other. However
>>> if both idmappers do happen to be configured, then we want to always
>>> choose the non-legacy type...
>>
>> On a quick check....  It looks like F17 has /usr/sbin/nfsidmap, and also
>> runs rpc.idmapd for the server.  While rpc.idmap does have a "-S"
>> option, it's not using that.
>>
>> But that should be easy to fix--I'll go look....
> 
> Steve, this, or do we want to modify the default value of RPCIDMAPDARGS
> in nfs.sysconfig?
Actually that looks like a good idea.. I'll make that happen... but
it will be a Fedora only thing... 

steved.
> 
> --b.
> 
> diff --git a/nfs-idmap.service b/nfs-idmap.service
> index 872ae09..93c1b3a 100644
> --- a/nfs-idmap.service
> +++ b/nfs-idmap.service
> @@ -7,7 +7,7 @@ After=nfs-server.service
>  Type=forking
>  StandardError=syslog+console
>  EnvironmentFile=-/etc/sysconfig/nfs
> -ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
> +ExecStart=/usr/sbin/rpc.idmapd -S $RPCIDMAPDARGS
>  
>  [Install]
>  WantedBy=nfs.target
> diff --git a/nfs.sysconfig b/nfs.sysconfig
> index 2d33cf3..4baa0c3 100644
> --- a/nfs.sysconfig
> +++ b/nfs.sysconfig
> @@ -24,7 +24,7 @@ RPCMOUNTDOPTS=""
>  STATDARG=""
>  #
>  # Optional arguments passed to rpc.idmapd. See rpc.idmapd(8)
> -RPCIDMAPDARGS=""
> +RPCIDMAPDARGS="-S"
>  #
>  # Optional arguments passed to rpc.gssd. See rpc.gssd(8)
>  RPCGSSDARGS=""
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
