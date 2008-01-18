From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 14:19:52 -0500
Message-ID: <1200683992.13348.4.camel@heimdal.trondhjem.org>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net>
	 <1200675753.7781.32.camel@heimdal.trondhjem.org>
	 <6FBCD100-A02A-4CA5-8329-A801846B14BC@oracle.com>
	 <1200679596.7781.37.camel@heimdal.trondhjem.org>
	 <004A35A1-29F1-4C3E-AD1A-B42EEF5B8C22@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33489 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757942AbYARTT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 14:19:56 -0500
In-Reply-To: <004A35A1-29F1-4C3E-AD1A-B42EEF5B8C22@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-18 at 13:11 -0500, Chuck Lever wrote:
> The plan is to include these scripts in nfs-utils during 2CQ08, after  
> the IPv6 work is complete.  There is some additional work to be done,  
> such as composing man pages for both scripts, adding appropriate  
> dependency information in the nfs-utils build scripts, and so on.

I'm of two minds about that. I agree that we need an iostat-like utility
in nfs-utils, but I'm wary about also adding in a new language
dependency on python.

