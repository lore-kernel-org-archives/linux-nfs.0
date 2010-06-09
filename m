From: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Subject: FW: Unable to mount nfs directories RHEL 4.8
Date: Tue, 8 Jun 2010 17:05:50 -0700
Message-ID: <620E93B2E5CC3B46BD811165E3335B8708C2A04E@0461-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cpmx2.mail.saic.com ([139.121.17.172]:43926 "EHLO
	cpmx2.mail.saic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756314Ab0FIAUx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 20:20:53 -0400
Received: from 0599-its-sbg03.saic.com ([139.121.20.253] [139.121.20.253]) by cpmx2.mail.saic.com with ESMTP id BT-MMP-4417616 for linux-nfs@vger.kernel.org; Tue, 8 Jun 2010 17:05:51 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Didn't see the original message, sorry if this is a duplicate

-----Original Message-----
From: Murata, Dennis 
Sent: Tuesday, June 08, 2010 3:26 PM
To: linux-nfs-owner@vger.kernel.org
Subject: Unable to mount nfs directories RHEL 4.8

We are using a modified RHEL 4.8 build accessing Netapp filers for data
directories.  The build has nfs-utils-1.0.6-93.EL4,
nfs-utils-lib-1.0.6-10.el4, kernel-largesmp-2.6.9-89.EL all x86_64.
After a period of use, on a very questionable network using tcp as the
nfs transport, workstation will start getting error messages in
/var/log/messages|dmesg and are not able to mount/access the data
directories.  A reboot is necessary to allow the mounts.  The time
period varies and seems to depend on the usage, but in general will
start within a week of moderate use.  The error messages are:

lockd: cannot monitor 192.168.10.133
lockd: failed to monitor 192.168.10.133
nsm_mon_unmon: rpc failed, status=-96
lockd: cannot monitor 192.168.10.133
lockd: failed to monitor 192.168.10.133
nsm_mon_unmon: rpc failed, status=-96
lockd: cannot monitor 192.168.10.133
lockd: failed to monitor 192.168.10.133

These errors are repeated as access to the filer (ip address has been
changed) is tried.  A ps on the workstation shows rpc.statd still
running, service nfslock status reports rpc.statd running.

If the nfs-utils rpm from RHEL 4.6 is loaded, nfs-utils-1.0.6-84.EL4,
the problem does not occur.  We have been testing a few workstations for
~two weeks without problem.  Any ideas?

TIA
Wayne 
