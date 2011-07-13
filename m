Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.uvm.edu ([132.198.101.168]:60387 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596Ab1GMQDG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 12:03:06 -0400
Received: from planck.uvm.edu (planck.uvm.edu [132.198.104.181])
	(authenticated bits=0)
	by smtp1.uvm.edu (8.14.2/8.14.2) with ESMTP id p6DG335f005198
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2011 12:03:04 -0400
From: Benjamin Coddington <bcodding@uvm.edu>
Content-Type: text/plain; charset=us-ascii
Subject: multiple service identities for svcgssd
Date: Wed, 13 Jul 2011 12:03:03 -0400
Message-Id: <3EA8A380-460C-4CDC-9591-7034D2E38D93@uvm.edu>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am working on a linux NFS cluster that requires a single svcgssd to establish contexts under multiple service names.

In this scenario, svcgssd can be called with "-n" so that it acquires creds at context creation.  After running this way I found svcgssd opens a file to the kerberos replay cache for every context/cred, eventually reaching ulimit.  For a busy cluster with many different client-user pairs that becomes a problem.  I am lost in the gss_krb5 code, but suspect that the kerberos code leaks credentials in this configuration.

Ondrej Palkovsky submitted a patch to specify multiple identities and acquire creds up-front using multiples of "-h": http://marc.info/?l=linux-nfsv4&m=123685185324902&w=2

I've updated that work to be current to nfs-utils-1.2.3 which solves our immediate problem, and it works well -- but running svcgssd with '-n' is still going to leak file handles to the replay cache.  What's the best way to fix this?  Can the created-on-the-fly cred can be re-used for subsequent contexts?

Ben