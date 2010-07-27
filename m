Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6460 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753819Ab0G0P2U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jul 2010 11:28:20 -0400
Subject: Re: iostat "await" like counter for measuring nfs latency
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com>
References: <Pine.LNX.4.64.1007271300180.2110@zuben.voltaire.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Jul 2010 17:27:58 +0200
Message-ID: <1280244478.2981.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-07-27 at 13:07 +0300, Or Gerlitz wrote:
> Doing some iscsi and nfs performance testing, I realized that iostat(1)
> doesn't support an "await" (*) like counter for measuring nfs latency.
> 
> Can tracking nfs latency be done in other means? is there a plan to
> extend the nfs iostats code to include such/similar counter?
> 
> thanks,
> 
> Or.
> 
> 
> (*) await - The average time (in milliseconds) for I/O requests issued
>     to the device to be served. This includes the time spent by the
>     requests in queue and the time spent servicing them.
> 
> 

The information is already available in /proc/self/mountstats. It is up
to iostat to start using it.

Trond
