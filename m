Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:58243 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933055Ab3FRT4K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 15:56:10 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Tue, 18 Jun 2013 13:55:49 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E92C1C90045
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 15:55:45 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IJthph291592
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 15:55:45 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IJtg2X018685
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 13:55:42 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r5IJtgVN018674
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 13:55:42 -0600
In-Reply-To: <1371568176.3868.5.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com> <1371568176.3868.5.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Message-ID: <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Tue, 18 Jun 2013 14:55:37 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS server uses UMNT as a signal to remove the client from its mount 
table. Also at this time the Server cleans up other information about the 
now disconnected client.  Why would the client attempt to access the NFS 
server once it has stated its going to unmount?  I do not see the point of 
the GETATTR request after UMNT call.


Christopher Vogan
Dept. W98 NFS Development & Test



From:   "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To:     Christopher T Vogan/San Jose/IBM@IBMUS, 
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   06/18/2013 10:19 AM
Subject:        Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel



On Tue, 2013-06-18 at 07:47 -0600, Christopher T Vogan wrote:
> The new linux 3.10.0-rc5 kernel gets NFSERR_STALE on un-mount.
> The reason is the Linux client is sending a GETATTR after the umnt 
> call/reply.
> This is a network trace of the umnt call/reply and the gettattr 
> afterwords.

This happens because the 'umount.nfs' utility calls the umnt RPC before
the actual umount system call.

Why would this trigger an NFSERR_STALE? Is the server using UMNT for
something other than just providing client usage stats? If so, what and
why?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



