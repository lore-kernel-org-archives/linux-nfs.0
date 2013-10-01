Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:57896 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab3JASR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 14:17:56 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 1 Oct 2013 14:17:55 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 91AB0C90045
	for <linux-nfs@vger.kernel.org>; Tue,  1 Oct 2013 14:17:52 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91IHqFb65404976
	for <linux-nfs@vger.kernel.org>; Tue, 1 Oct 2013 18:17:52 GMT
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91IHqip020562
	for <linux-nfs@vger.kernel.org>; Tue, 1 Oct 2013 12:17:52 -0600
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r91IHquH020541
	for <linux-nfs@vger.kernel.org>; Tue, 1 Oct 2013 12:17:52 -0600
Date: Tue, 1 Oct 2013 13:17:50 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: NFS with ActiveDirectory+Kerberos
Message-ID: <20131001181750.GA24424@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

We are using RHEL6.1 as an NFS server, and we have configured an RHEL6.2
system as an NFS client. We configured AD+Kerberos set up on both these
machines. The kerberos TGT ticket is set to expire after a long time,
but the kerberos service ticket is set to expire only after a short time
(10 minutes), but the service ticket is renewable!  NFS I/O fails around
when service ticket expires (EIO or EACCESS). If we retry the command
(or any command that generates NFS I/O), the service ticket gets renewed
and everything works until the next service expiry time.

Could this be an AD (Active Directory) related issue? Do auto renewing
service tickets work in NFS (nfs-utils-1.2.3-15.el6.x86_64)?  We have
tried with 10 hour service ticket expiry time as well. Same issue, the 
I/O fails after 10 hours!

I am not familiar with kerberos and NFS security. Is there a way to
manually (cron/script) renew those tickets and make it work without NFS
errors? I would appreciate any help.

Regards, Malahal.

