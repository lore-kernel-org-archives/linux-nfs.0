Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:46172 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab2CaQXm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Mar 2012 12:23:42 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SE15W-0005Kz-MU
	for linux-nfs@vger.kernel.org; Sat, 31 Mar 2012 18:23:38 +0200
Received: from p3e9bbfe5.dip.t-dialin.net ([62.155.191.229])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 31 Mar 2012 18:23:38 +0200
Received: from ponto by p3e9bbfe5.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 31 Mar 2012 18:23:38 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <ponto@pontohonk.de>
Subject: Re: nfsd hangs for more than 120 seconds
Date: Sat, 31 Mar 2012 18:17:29 +0200
Message-ID: <p9nj49-5hf.ln1@homer.bruehl.pontohonk.de>
References: <0v7j49-4jc.ln1@homer.bruehl.pontohonk.de> <1333206116.17974.39.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

> On Sat, 2012-03-31 at 13:55 +0200, Christoph Bartoschek wrote:
>> Hi,
>> 
>> we use Ubuntu 10.04.3 LTS and often get a traceback for NFS indicating
>> that the daemon hangs for several seconds. At the same time some client
>> machines cannot access the server and have to wait. After some minutes
>> everything goes on.
>> 
>> What could cause the problem? Is there anything we should change?
>> 
>> Here is the message in the kernel log:
>> 
>> [330573.697121] INFO: task nfsd:1376 blocked for more than 120 seconds.
>> [330573.708375] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> [disables
>> this message.
>> [330573.730773] nfsd          D 0000000000000001     0  1376      2
>> 0x00000000
>> [330573.730776]  ffff88061c21bdc0 0000000000000046 0000000000015f00
>> 0000000000015f00
>> [330573.730779]  ffff88061c111ad0 ffff88061c21bfd8 0000000000015f00
>> ffff88061c111700
>> [330573.730781]  0000000000015f00 ffff88061c21bfd8 0000000000015f00
>> ffff88061c111ad0
>> [330573.730784] Call Trace:
>> [330573.730788]  [<ffffffff81559e67>] __mutex_lock_slowpath+0x107/0x190
>> [330573.730796]  [<ffffffffa012300f>] ? svc_authorise+0x3f/0x50 [sunrpc]
> 
> At a guess, I'd say that your mountd  or rpc.svcgssd is probably
> busy/hanging, causing the kernel NFS daemon to hang while it waits to
> authorise a client or user. Typically, you will see the above in the
> case of a kerberos, NIS or ldap outage.
> 
> So are you using NIS or ldap-based netgroups in your /etc/exports, or
> are your clients perhaps mounting with sys=krb5?

We are still using NFS3 and NIS. 

We are also sometimes seeing the following problem that might be related:

One user suddenly has no access to a directory and its subdirectories on a 
NFS share. The user always gets "permission denied". The access bits and 
group memberships did not change.

At the same time all other users within the same groups can access the 
directory on the same client machine and on other client machines.

After about 15 minutes the problem vanishes by itself. The user no longer 
gets "permission denied" and everything is normal.

This happens about twice a week for different users. We see no pattern in 
which user is affected and when this happens.

Thanks 
Christoph

