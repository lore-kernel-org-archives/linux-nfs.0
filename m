Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:59198 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756290Ab2KZVt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 16:49:59 -0500
Received: from sc9-mailhost1.vmware.com (sc9-mailhost1.vmware.com [10.113.161.71])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 9D76C28828
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 13:49:58 -0800 (PST)
Received: from zcs-prod-mta-2.vmware.com (zcs-prod-mta-2.vmware.com [10.113.163.64])
	by sc9-mailhost1.vmware.com (Postfix) with ESMTP id 9945718291
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 13:49:58 -0800 (PST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zcs-prod-mta-2.vmware.com (Postfix) with ESMTP id 8BD8DE1BB0
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 13:49:58 -0800 (PST)
Received: from zcs-prod-mta-2.vmware.com ([127.0.0.1])
	by localhost (zcs-prod-mta-2.vmware.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hVnKQsjfjMq7 for <linux-nfs@vger.kernel.org>;
	Mon, 26 Nov 2012 13:49:58 -0800 (PST)
Received: from zcs-prod-mta-2.vmware.com (localhost.localdomain [127.0.0.1])
	by zcs-prod-mta-2.vmware.com (Postfix) with ESMTP id 69DECE1B6A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 13:49:58 -0800 (PST)
Received: from zimbra-prod-mbox-2.vmware.com (lbv-sc9-t2prod2-int.vmware.com [10.113.160.246])
	by zcs-prod-mta-2.vmware.com (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 13:49:57 -0800 (PST)
Date: Mon, 26 Nov 2012 13:49:57 -0800 (PST)
From: Andrei Warkentin <awarkentin@vmware.com>
To: linux-nfs@vger.kernel.org
Message-ID: <864189844.31754280.1353966597599.JavaMail.root@vmware.com>
In-Reply-To: <477254919.31693823.1353963259597.JavaMail.root@vmware.com>
Subject: Race between NFS server thread increase / decrease
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi NFSD developers,

I've found what I think is an interesting problem that occurs on single-CPU machines as far as I can tell.

Basically the following snippet will occasionally loop forever printing that one thread is still running. Further
attempts to run "/usr/sbin/rpc.nfsd 0" don't help.

/usr/sbin/rpc.nfsd 1
/usr/sbin/rpc.nfsd 0
while [ ! $[`cat /proc/fs/nfsd/threads`] -eq 0 ]; do
        echo $[`cat /proc/fs/nfsd/threads`] still running
        sleep .1
done

I've not looked a whole lot at it. It appears that although the paths calling svc_set_num_threads synchronize on nfsd_mutex, the code doesn't seem to try waiting on the number of threads to reach the desired count.

What do you guys think?

Thanks.

A
