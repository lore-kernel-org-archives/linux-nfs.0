From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Tue, 1 Jul 2008 09:13:52 +0530
Message-ID: <OF910333D8.6F8A0AB9-ON65257479.00140CE0-65257479.00147EFA@in.ibm.com>
References: <76bd70e30806300825t6490477dpb8ce3ee48a0a6777@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>, chucklever@gmail.com,
	linux-nfs@vger.kernel.org, "Peter Staubach" <staubach@redhat.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:51194 "EHLO
	e28esmtp07.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750719AbYGADox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 23:44:53 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m613iiEd017171
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 09:14:44 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m613iN5V1491058
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 09:14:24 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m613ihmV020147
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 09:14:43 +0530
In-Reply-To: <76bd70e30806300825t6490477dpb8ce3ee48a0a6777-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

> As I understand it, "lo" is effectively a virtualized network device
> with point-to-point routing.  Looping back through a real NIC can, in
> many cases, go all the way down to the network hardware and back, and
> is likely subject to routing decisions in your system's network layer.
>  So I would expect them to be different in most cases.

Atleast in the linux stack, if you address a local network device, the
kernel does a route lookup to figure out which interface to send the
packet out on, and this results in using lo.

Thanks,

- KK

