Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52741 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702Ab1FCMcg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2011 08:32:36 -0400
Subject: Re: NFS3 + kerberos: performance issues
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vladimir Elisseev <vovan@vovan.nl>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 03 Jun 2011 08:32:34 -0400
In-Reply-To: <1307086159.1052.19.camel@vovan.net.home>
References: <1307086159.1052.19.camel@vovan.net.home>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307104354.2477.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-06-03 at 09:29 +0200, Vladimir Elisseev wrote: 
> Hello,
> 
> After using nfs3 with kerberos for a while I discovered very poor
> performance for some file operations like creation of files. There are
> two observations:
> - the overal nfs3 performance is good: for instance copying large files
> works fine
> - this poor performance is definitely related to kerberos as the same
> volume exported without sec=krb5 works ~10 times faster with creating
> files
> I'd appreciate if somebody can explain this behaviour?
> 
> Below are some details about NFS server and client:
> server:
> - kernel 2.6.36
> - export options rw,sec=krb5,no_root_squash,no_subtree_check
> - nfs-utils 1.2.3
> 
> client:
> - kernel 2.6.38 or 2.6.39 
> - mout options (from /proc/mounts):
> rw,nosuid,nodev,noatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,mountaddr=192.168.1.219,mountvers=3,mountport=32767,mountproto=tcp,local_lock=none,addr=192.168.1.219
> 
> when the same volume exported without sec=krb5, the only option changes
> in /proc/mounts is sec=sys

Can you please tell us a bit more about how you are measuring this? I
might expect a x10 performance difference if the workload is dominated
by the actual setting up of the RPCSEC_GSS session (i.e. you are timing
mount+create one file or something like that). If we're talking about a
workload where the RPCSEC_GSS negotiation can be neglected, however
(mount+create 100000 files), I wouldn't expect any measurable
performance impact from 'sec=krb'.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

