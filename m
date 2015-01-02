Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:57702 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbABSkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Jan 2015 13:40:06 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y778l-0001H4-2p
	for linux-nfs@vger.kernel.org; Fri, 02 Jan 2015 19:40:03 +0100
Received: from barriere.frankfurter-softwarefabrik.de ([217.11.197.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jan 2015 19:40:03 +0100
Received: from lvml by barriere.frankfurter-softwarefabrik.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jan 2015 19:40:03 +0100
To: linux-nfs@vger.kernel.org
From: Lutz Vieweg <lvml@5t9.de>
Subject: Re: xprt_adjust_timeout followed by lockd: server not responding
 / server OK
Date: Fri, 02 Jan 2015 18:52:30 +0100
Message-ID: <m86lsu$4l9$1@ger.gmane.org>
References: <1416877610.325.37.camel@abezella-laptop.us.archive.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
In-Reply-To: <1416877610.325.37.camel@abezella-laptop.us.archive.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/25/2014 02:06 AM, andrew bezella wrote:
> [ 3809.070778] xprt_adjust_timeout: rq_timeout = 0!
> [ 3809.070784] lockd: server nfs-home not responding, still trying
> [ 3809.332988] lockd: server nfs-home OK

I'm seeing the very same annoying symptom every few minutes on a
CentOS 7 client with kernel 3.17.1 (server also running CentOS 7
with the same kernel).

Both servers are connected to the same 10GBit/s switch and don't
currently have much load...

Regards,

Lutz Vieweg

