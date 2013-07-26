Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 82-198-214-42.briteline.de ([82.198.214.42]:36001 "EHLO
	mail.artcom-gmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094Ab3GZMIw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jul 2013 08:08:52 -0400
Date: Fri, 26 Jul 2013 14:08:49 +0200
From: Peter Funk <pf@artcom-gmbh.de>
To: Dick Streefland <dick.streefland@altium.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not
 available?
Message-ID: <20130726120849.GA12584@pfmaster>
References: <20130724091856.GA30866@pfmaster>
 <6f01.51efd09f.c2ac3@altium.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6f01.51efd09f.c2ac3@altium.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dick Streefland wrote 24.07.2013 13:03:
> Peter Funk <pf@artcom-gmbh.de> wrote:
> | We've researched this question for quite a while now and nobody here
> | found a solution to the following problem:
> | 
> |  1: A Linux computer is NFS client of some other Linux NFS server
> |     and has some active mounts and some processes working with files 
> |     on that NFS server.  
> | 
> |  2: Now the NFS server becomes unavailable and a system administrator 
> |     wants to clean up the situation on the NFS client computer without 
> |     having to reboot this client computer.
> | 
> | Is this possible?  And if how exactly?
> 
> What you could try is temporarily add the IP number of the dead NFS
> server to another NFS server. The other NFS server should reject any
> request for the dead mount, and the client can continue with an error.

Indeed: This workaround seems to work!

Assume example: The NFS-server has IP 192.168.123.45 and the client
has also the nfs-kernel-server package installed and it is running.
Then this sequence on the client did the trick::

    ifconfig eth0:fakesrv 192.168.123.45 up
    umount -f -l ....
    umount -f -l ....
    ....
    ifconfig eth0:fakesrv down

Best Regards and many thanks for your suggestion,
Peter Funk
-- 
Peter Funk, home: ✉Oldenburger Str.86, D-27777 Ganderkesee
mobile:+49-179-640-8878 phone:+49-421-20419-0 <http://www.artcom-gmbh.de/>
office: ArtCom GmbH, ✉Haferwende 2, D-28357 Bremen, Germany
