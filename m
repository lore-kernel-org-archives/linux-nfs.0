Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from iad2.emailsrvr.com ([207.97.227.212]:56030 "EHLO
	smtp161.iad.emailsrvr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753772AbZCLBMg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 21:12:36 -0400
Received: from relay26.relay.iad.mlsrvr.com (localhost [127.0.0.1])
	by relay26.relay.iad.mlsrvr.com (SMTP Server) with ESMTP id 25FAF1B41D5
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 20:57:32 -0400 (EDT)
Received: by relay26.relay.iad.mlsrvr.com (Authenticated sender: alfred-AT-von-campe.com) with ESMTPSA id 13B591B41D2
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 20:57:31 -0400 (EDT)
Message-Id: <96B48952-DA6E-457C-AFAF-B8A96A29CDF1@von-campe.com>
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
To: linux-nfs@vger.kernel.org
From: Alfred von Campe <alfred@von-campe.com>
Subject: Intermittent NFS problems with NetApp server
Date: Wed, 11 Mar 2009 20:57:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been experiencing some intermittent problems accessing at NetApp
server via NFS and automount.  I'm running CentOS 5.2 (fully updated)
on all my servers and workstations.  Usually, everything is working
just fine, when suddenly we get the following error:

    /bin/sh: /home/epd/srcref/swtools/Crontabs/ 
run_release_requests.sh: Permission denied

This is actually an email from cron because we try to run that shell
script every minute (yes, the crontab entry is * * * * * /home/epd/
srcref/swtools/Crontabs/run_release_requests.sh), and /home/epd is an
automounted directory.  Here is its map entry:

    epd -rw,nointr,rsize=32768,wsize=32768 XXXXXX:/epd

When this is happening, other users can successfully access that
directory on the server.  The directory is actually mounted
correctly, and unmounting doesn't fix the issue.  Furthermore, the
same user that is being denied access, can successfully access that
directory on a different server.  The problem usually lasts about 20
minutes and then resolves itself.  We have been pulling our hair out
trying to debug this problem, because it's intermittent and the debug
window is fairly short.

Recently we have been getting help from one of the NetApp admins, and
he ran a command on the NetApp that produced the following warning:

    The TCP receive window advertised by NFS client XXXXXXX is 5888.
    This is less than the recommended value of 32768 bytes.
    You should increase the TCP receive buffer size for NFS on the  
client.

Some googling around got me to check these values for TCP:

    # sysctl net.ipv4.tcp_mem
    net.ipv4.tcp_mem = 98304        131072  196608
    # sysctl net.ipv4.tcp_rmem
    net.ipv4.tcp_rmem = 4096        87380   4194304
    # sysctl net.ipv4.tcp_wmem
    net.ipv4.tcp_wmem = 4096        16384   4194304

So these seem fine to me (i.e., the max is greater than 32768).  Is
there an NFS (as opposed to TCP) setting I should be tweaking?  Any
ideas why the NetApp is issuing those warnings?  Any other
suggestions on how to debug this problem?

Thanks,
Alfred
