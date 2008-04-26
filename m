From: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Sat, 26 Apr 2008 16:29:46 +0100
Message-ID: <fuvhpa$dm3$1@ger.gmane.org>
References: <20080423214929.GA24387@uio.no> <481348E4.3000003@kingswood-consulting.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:35202 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753493AbYDZPaF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Apr 2008 11:30:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JpmLi-0005s1-Hm
	for linux-nfs@vger.kernel.org; Sat, 26 Apr 2008 15:30:02 +0000
Received: from 88-97-16-53.dsl.zen.co.uk ([88.97.16.53])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:30:02 +0000
Received: from frank by 88-97-16-53.dsl.zen.co.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:30:02 +0000
In-Reply-To: <481348E4.3000003-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank A. Kingswood wrote:
>    ssh -L2049:srv:2049 -L2050:srv:2050 -L2051:srv:2051ser@gateway

sorry, duff mailer and message wrapping got that. it should say

ssh -L2049:srv:2049 -L2050:srv:2050 -L2051:srv:2051 user@gateway

