Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40345 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757776Ab0JLQ32 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 12:29:28 -0400
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9CGTPj2017790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 16:29:26 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o9CGTKxK015808
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 16:29:21 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: whither NFS umount?
Date: Tue, 12 Oct 2010 12:29:02 -0400
Message-Id: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been looking at a bug where "mount.nfs -o remount" wipes all the mount options for that mount out of /etc/mtab, thereby making umounting break.

This is a tough nut to crack in user space... Not even utils-linux-ng seems to get mtab option rewriting correct in this case.

Jeff suggested a few weeks ago that we should just chuck user space umount and go with a kernel umount implementation.  I'm beginning to think that is a good strategy, even though a UMNT request is advisory.

  + Only the kernel knows when the last instance of a shared mount point is gone -- only then should a UMNT be sent to the server

  + The kernel might do a delayed lazy UMNT.  It would avoid sending a UMNT until the client is actually done using the export.  Today we just don't send UMNT at all in this case

  + The kernel preserves the original mount options in an internal data structure rather than in /etc/mtab, even after a remount.  This eliminates the NFS requirement for /etc/mtab -- one step closer to getting rid of it

  + The kernel already handles umounts for under-the-cover NFSv4 mounts, right?

  + The kernel is the authority on what is an NFSv4 mount point, so it knows exactly what kind of umount to do every time (send a UMNT or not)

  + There is already a UMNT client in the kernel, used when the kernel's MNT request fails such that a UMNT is needed

Thoughts, comments?

-- 
chuck[dot]lever[at]oracle[dot]com




