From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 15:27:18 +0530
Message-ID: <OF8CAC1A08.19AB248E-ON65257478.003203B5-65257478.0036AF80@in.ibm.com>
References: <76bd70e30806270706x7cbfd291l6cb6d0cc5e81771@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>, chucklever@gmail.com,
	linux-nfs@vger.kernel.org, "Peter Staubach" <staubach@redhat.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:47667 "EHLO
	e28esmtp06.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754779AbYF3J62 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 05:58:28 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5U9w5hu029261
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:28:05 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U9us2n962708
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:26:54 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5U9w4j4026599
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:28:05 +0530
In-Reply-To: <76bd70e30806270706x7cbfd291l6cb6d0cc5e81771-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

chucklever@gmail.com wrote on 06/27/2008 07:36:44 PM:

> > But loopback is better than actual network traffic.
>
> What precisely do you mean by that?

Sorry I was not clear. I meant that the loopback will be better than
actual traffic between different server/client.

> You are testing with the client and server on the same machine.  Is
> the loopback mount over the lo interface, but you mount the machine's
> actual IP address for the "network" test?

Actually isn't that the same? I am using localhost in any case.

> It would be interesting to compare a network-only performance test
> (like iPerf) for loopback and for going through the NIC.

iperf (one thread, 64K I/O size, 30 secs):
      NIC: 445 MB/s
      Loopback: 735 MB/s

In retrospect, for disk I/O:
      /local: 39 MB/s
      /nfs (loopback): 29 MB/s            (25.5% drop)
      /nfs (from a real server): 27 MB/s  (30.5% drop, only point is that
            this is a different disk on a different system and it doesn't
make
            much sense to compare this to /local).

Thanks,

- KK

