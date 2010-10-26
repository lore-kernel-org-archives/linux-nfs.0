Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477Ab0JZUJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 16:09:37 -0400
Message-ID: <4CC7357D.8090106@RedHat.com>
Date: Tue, 26 Oct 2010 16:09:33 -0400
From: Steve Dickson <SteveD@redhat.com>
To: ShaunR <mailinglists@unix-scripts.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and portmap
References: <ia761h$921$1@dough.gmane.org>
In-Reply-To: <ia761h$921$1@dough.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/26/2010 02:18 PM, ShaunR wrote:
> Everything i keep reading tells me that NFS4 does not need portmap but
> for some reason on the NFS server ( CentOS 5.x ) i cannot get the nfs
> services started unless portmap is running first.
> 
> On the server i modified /etc/sysconfig/nfs with the following options
> MOUNTD_NFS_V1="no"
> MOUNTD_NFS_V2="no"
> RPCNFSDARGS="-N 2 -N 3 -U"
> 
> For some reason if i uncomment MOUNTD_NFS_v3="no" i get errors.
> 
> On the client, again a CentOS 5.x machine but with a newer custom built
> kernel, If i do not start portmap then when i run mount it takes about 2
> minutes for the filesystem to mount and i see the following messages in
> /var/log/messages
> 
> Oct 26 10:25:30 host kernel: rpcbind: server localhost not responding,
> timed out
> 
> If i start portmap, the mount command completed in a few seconds.
> 
> 
> My goal here to is run/support NFSv4 Only.
I think you are running into a known problem of when the v4
server comes it uses some legacy code that blindly does 
"unregister all my previous existences" to rpcbind.
So that unregister hangs for a bit if rpcbind is not
running... This was fixed in later releases... 

steved.
