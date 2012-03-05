Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:49872 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab2CEXQv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 18:16:51 -0500
Received: from [192.168.1.3] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q25NHQUH029520
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 00:17:33 +0100
Message-ID: <4F554954.9050901@steve-ss.com>
Date: Tue, 06 Mar 2012 00:16:36 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: nfs3 lockd: cannot monitor errors
References: <4F520CB4.1030203@steve-ss.com>
In-Reply-To: <4F520CB4.1030203@steve-ss.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/03/12 13:21, steve wrote:
> Hi
> We recently switched to nfs3 from nfs4 and now we're getting lots of
> lockd errors. We can remove the error by mounting with:
> -o local_lock=posix
>
> We had to switch to be able to use the posix acl we had set on the share.
>
> What problems may we face by setting the local_lock?
> Thanks,
> Steve
>

Hi
Sorry to bump
This is openSUSE 12.1. All the references to lockd probs seem to come 
from 10 or so years ago.

Could anyone give me a one liner as to where to start looking? I've gone 
through all the usual channels.

Cheers,
Steve

Server:
Mar  5 16:24:46 hh3 kernel: [16760.656609] lockd: cannot monitor hh6

  ps aux | grep rpc
root      1214  0.0  0.1   2356   656 ?        Ss   Mar05   0:00 
/sbin/rpcbind
root      1821  0.0  0.0      0     0 ?        S<   Mar05   0:00 [rpciod]
root      4649  0.0  0.0   2416   416 ?        Ss   Mar05   0:00 
/usr/sbin/rpc.idmapd
root      4668  0.0  0.3   4092  1508 ?        Ss   Mar05   0:00 rpc.gssd
root      5192  0.0  0.2   3840  1096 ?        Ss   Mar05   0:00 
/usr/sbin/rpc.svcgssd
root      5206  0.0  0.1   3032   568 ?        Ss   Mar05   0:00 
/usr/sbin/rpc.mountd --no-nfs-version 4
statd     5243  0.0  0.1   2584   652 ?        Ss   Mar05   0:00 
/usr/sbin/rpc.statd --no-notify


rpcinfo
    program version netid     address                service    owner
     100000    4    tcp6      ::.0.111               portmapper superuser
     100000    3    tcp6      ::.0.111               portmapper superuser
     100000    4    udp6      ::.0.111               portmapper superuser
     100000    3    udp6      ::.0.111               portmapper superuser
     100000    4    tcp       0.0.0.0.0.111          portmapper superuser
     100000    3    tcp       0.0.0.0.0.111          portmapper superuser
     100000    2    tcp       0.0.0.0.0.111          portmapper superuser
     100000    4    udp       0.0.0.0.0.111          portmapper superuser
     100000    3    udp       0.0.0.0.0.111          portmapper superuser
     100000    2    udp       0.0.0.0.0.111          portmapper superuser
     100000    4    local     /var/run/rpcbind.sock  portmapper superuser
     100000    3    local     /var/run/rpcbind.sock  portmapper superuser
     100005    1    udp       0.0.0.0.178.110        mountd     superuser
     100005    1    tcp       0.0.0.0.136.30         mountd     superuser
     100005    1    udp6      ::.145.115             mountd     superuser
     100005    1    tcp6      ::.220.209             mountd     superuser
     100005    2    udp       0.0.0.0.163.232        mountd     superuser
     100003    2    tcp       0.0.0.0.8.1            nfs        superuser
     100003    3    tcp       0.0.0.0.8.1            nfs        superuser
     100227    2    tcp       0.0.0.0.8.1            nfs_acl    superuser
     100227    3    tcp       0.0.0.0.8.1            nfs_acl    superuser
     100003    2    udp       0.0.0.0.8.1            nfs        superuser
     100003    3    udp       0.0.0.0.8.1            nfs        superuser
     100227    2    udp       0.0.0.0.8.1            nfs_acl    superuser
     100227    3    udp       0.0.0.0.8.1            nfs_acl    superuser
     100005    2    tcp       0.0.0.0.210.206        mountd     superuser
     100005    2    udp6      ::.150.240             mountd     superuser
     100003    2    tcp6      ::.8.1                 nfs        superuser
     100003    3    tcp6      ::.8.1                 nfs        superuser
     100227    2    tcp6      ::.8.1                 nfs_acl    superuser
     100227    3    tcp6      ::.8.1                 nfs_acl    superuser
     100003    2    udp6      ::.8.1                 nfs        superuser
     100003    3    udp6      ::.8.1                 nfs        superuser
     100227    2    udp6      ::.8.1                 nfs_acl    superuser
     100227    3    udp6      ::.8.1                 nfs_acl    superuser
     100021    1    udp       0.0.0.0.141.165        nlockmgr   superuser
     100021    3    udp       0.0.0.0.141.165        nlockmgr   superuser
     100021    4    udp       0.0.0.0.141.165        nlockmgr   superuser
     100021    1    tcp       0.0.0.0.173.52         nlockmgr   superuser
     100021    3    tcp       0.0.0.0.173.52         nlockmgr   superuser
     100021    4    tcp       0.0.0.0.173.52         nlockmgr   superuser
     100021    1    udp6      ::.208.135             nlockmgr   superuser
     100021    3    udp6      ::.208.135             nlockmgr   superuser
     100021    4    udp6      ::.208.135             nlockmgr   superuser
     100021    1    tcp6      ::.175.226             nlockmgr   superuser
     100021    3    tcp6      ::.175.226             nlockmgr   superuser
     100021    4    tcp6      ::.175.226             nlockmgr   superuser
     100005    2    tcp6      ::.200.118             mountd     superuser
     100005    3    udp       0.0.0.0.217.9          mountd     superuser
     100005    3    tcp       0.0.0.0.185.184        mountd     superuser
     100005    3    udp6      ::.226.152             mountd     superuser
     100005    3    tcp6      ::.204.113             mountd     superuser
     100024    1    udp       0.0.0.0.131.53         status     103
     100024    1    tcp       0.0.0.0.130.61         status     103
     100024    1    udp6      ::.140.153             status     103
     100024    1    tcp6      ::.179.31              status     103


