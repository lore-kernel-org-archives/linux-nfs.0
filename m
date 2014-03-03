Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail3.conversis.de ([213.203.208.210]:52562 "EHLO
	mail3.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaCCGJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 01:09:13 -0500
Received: from [192.168.0.100] (ip-178-201-213-194.unitymediagroup.de [178.201.213.194])
	by mail3.conversis.de (Postfix) with ESMTP id EBCCF1570021
	for <linux-nfs@vger.kernel.org>; Mon,  3 Mar 2014 06:47:52 +0100 (CET)
Message-ID: <53141788.9030209@conversis.de>
Date: Mon, 03 Mar 2014 06:47:52 +0100
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Temporary hangs when using locking with apache+nfsv4
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I'm experimenting with using NFSv4 as storage for web servers and while 
regular file access seems to work fine as soon as I bring flock() into 
play things become more problematic.
I've create a tiny test php script that basically opens a file, locks it 
using flock(), writes that fact into a log file (on a local filesystem), 
performs a usleep(1000), writes into the log that it is about to unlock 
the file and finally unlocks it.
I invoke that script using ab with a concurrency of 20 for a few 
thousand requests.

The result is that while 99% of the request respond quickly a few 
request seem to hang for up to 30 seconds. According to the log file 
they must eventually succeed since I see all expected entries and the 
locking seems to work as well since all entries are in the expected order.

Is it expected that these long delays happen? When I comment the locking 
function out these hangs disappear.
Are there some knobs to tune NFS and make it behave better in these 
situations?

Regards,
   Dennis
