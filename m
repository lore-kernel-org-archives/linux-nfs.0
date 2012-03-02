Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:38271 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab2CBTrA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 14:47:00 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Mar 2012 12:47:00 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id CDA6019D8048
	for <linux-nfs@vger.kernel.org>; Fri,  2 Mar 2012 12:46:52 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q22JkvOF170198
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:46:57 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q22Jku7I027439
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:46:57 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q22JkukZ027429
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:46:56 -0700
Date: Fri, 2 Mar 2012 13:46:55 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: strip of extra slashes in device name
Message-ID: <20120302194655.GB28389@us.ibm.com>
References: <1330707221-4005-1-git-send-email-steved@redhat.com>
 <20120302184556.GA6880@us.ibm.com>
 <4F511C95.2040806@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F511C95.2040806@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> 
> 
> On 03/02/2012 01:45 PM, Malahal Naineni wrote:
> > My kernel doesn't seem to strip '/' from its /proc/mounts. What kernel
> > are you using? 
> a later RHEL6 kernel... but I see the same thing with Fedora f16 kernels (3.2)
> as well... What kernel are you using?

Using 3.3.0-rc1+ kernel.
[root@elm3c105 ~]# grep mnt /proc/mounts 
elm3c104:///server/ /mnt nfs rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=9.47.69.104,mountvers=3,mountport=929,mountproto=udp,local_lock=none,addr=9.47.69.104 0 0

I must be missing something, I see the same thing in RHEL6.2 version of
Linux.

Regards, Malahal.

