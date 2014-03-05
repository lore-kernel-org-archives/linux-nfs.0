Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:7698 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868AbaCERp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 12:45:27 -0500
Received: from zimbra.xes-mad.com (zimbra.xes-mad.com [10.52.0.127])
	by xes-mad.com (8.13.8/8.13.8) with ESMTP id s25HjPLv026068
	for <linux-nfs@vger.kernel.org>; Wed, 5 Mar 2014 11:45:25 -0600
Date: Wed, 5 Mar 2014 11:45:24 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: linux-nfs@vger.kernel.org
Message-ID: <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
Subject: Optimal NFS mount options to safely allow interrupts and timeouts
 on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Is it safe to use the "soft" mount option with proto=tcp on newer kernels (e.g
3.2 and newer)? Currently using the "defaults" nfs mount options on Ubuntu
12.04 results in processes blocking forever in uninterruptable sleep if they
attempt to access a mountpoint while the NFS server is offline. I would prefer
that NFS simply return an error to the clients after retrying a few times, 
however I also cannot have data loss. From the man page, I think these options
will give that effect?
soft,proto=tcp,timeo=10,retrans=3

>From my understanding, this will cause NFS to retry the connection 3 times (once
per second), and then if all 3 are unsuccessful return an error to the
application. Is this correct? Is there a risk of data loss or corruption by
using "soft" in this way? Or is there a better way to approach this?

Thanks,

Andrew Martin
