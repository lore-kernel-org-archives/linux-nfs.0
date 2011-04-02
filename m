Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42399 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab1DBI4l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Apr 2011 04:56:41 -0400
Message-ID: <4D96E4C5.2080302@suse.cz>
Date: Sat, 02 Apr 2011 10:56:37 +0200
From: Jiri Slaby <jslaby@suse.cz>
To: linux-kernel@vger.kernel.org
CC: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
        ML netdev <netdev@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jiri Slaby <jirislaby@gmail.com>
Subject: nfs client doesn't work [was: mmotm 2011-03-31-14-48 uploaded]
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
In-Reply-To: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/31/2011 11:48 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to

Hi, nfs client is defunct in this kernel. Tcpdump says:
10:51:55.489717 IP 10.20.11.33.759945860 > 10.20.3.2.2049: 132 getattr
fh 0,0/24
10:51:55.515927 IP 10.20.3.2.2049 > 10.20.11.33.759945860: reply ok 44
getattr ERROR: Operation not permitted
10:51:55.515949 IP 10.20.11.33.921 > 10.20.3.2.2049: Flags [.], ack
3569361440, win 115, options [nop,nop,TS val 599750 ecr 255058541], length 0
10:52:04.130310 IP 10.20.11.33.793500292 > 10.20.3.2.2049: 76 getattr fh
0,0/24
10:52:04.152178 IP 10.20.3.2.2049 > 10.20.11.33.793500292: reply ok 44
getattr ERROR: Operation not permitted

If I run the same mount command (mount -oro,intr host:dir mountpoint)
from within a virtual machine with 2.6.38.2 there, everything mounts OK.

thanks,
-- 
js
suse labs
