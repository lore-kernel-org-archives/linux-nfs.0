From: Jim Anderson <ezjab-EkmVulN54Sk@public.gmane.org>
Subject: (k)ubuntu NFS buy
Date: Fri, 29 Apr 2011 09:34:00 -0400
Message-ID: <4DBABE48.1050901@ieee.org>
Reply-To: ezjab-EkmVulN54Sk@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:40437 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758645Ab1D2NeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 09:34:14 -0400
Received: from [192.168.0.9] ([unknown] [70.111.147.108])
 by vms173003.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0LKF00EJ51OLPTM0-q7IJPNDOu5nvnU/dHKwDPnL67TkHkek2@public.gmane.org> for
 linux-nfs@vger.kernel.org; Fri, 29 Apr 2011 08:33:57 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

I'm having a problem with NFS using Linux Kubuntu 10.10. I have logged 
my problem at the Kubuntu 10.10 forum and thus far I have had no 
response. Since Kubuntu/Debian package NFS with their release, it does 
not surprise me that I have had no response as yet.

I was thinking and realised that I probably need help from the 
developers. My problem seems like it is due to a bug in NFS, although it 
could easily be something wrong with my environment or the packaging. I 
did see some similar problems on the net with Red Hat.

Anyway, below is my write up from the Kubuntu forum.

Can you tell my problem is a known bug with NFS?

Jim Anderson



___________________________________________________________
 From Kubutu Form - April 29, 2010.
_________________________________________________________
I'm running a home network and I used NFS to share files between the 
Linux PCs. Everything was working fine
until 2 days ago, when I started getting error messages that I could not 
store files on remote servers. I tried
rebooting and mounting a file system from the server and I got the 
following message:

mount.nfs: requested NFS version or transport protocol is not supported

The client is running Kubuntu 10.10 with NFS 1:1.2.2-1Ubuntue1.1. The 
server is running NFS 1:1.2.0-2. The older
version is not that old and I was surprised at the apparent 
incompatibility that suddenly appeared. Rather that
try to figure out what was in compatible, I decided to upgrade the 
server to Kubuntu 10.10 so that the NFS
versions are identical. After installing NFS on the server, I am still 
getting the same error message.

I did a search on the error message and I found the following Ubuntu 
bug: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/656889
According to this bug report, This is a bug and it is not fixed in 10.10 
final release.

Do I move onto Kubuntu 11.04 or back to Kubuntu 10.04?
___________________________________________________________



-- 
Jim Anderson
ezjab-EkmVulN54Sk@public.gmane.org
(908)329-0586
