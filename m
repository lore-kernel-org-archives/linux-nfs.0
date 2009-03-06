From: "Kevin W. Rudd" <solgato@us.ibm.com>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Fri, 6 Mar 2009 14:51:03 -0800 (PST)
Message-ID: <alpine.LFD.1.10.0903061448560.3949@w-kevinr.beaverton.ibm.com>
References: <49760685.4030409@redhat.com>  <1232475301.7055.14.camel@heimdal.trondhjem.org>  <alpine.LFD.1.10.0903050829420.3949@w-kevinr.beaverton.ibm.com>  <1236279188.13361.30.camel@heimdal.trondhjem.org>  <alpine.LFD.1.10.0903051135040.3949@w-kevinr.beaverton.ibm.com>
 <1236370937.7244.52.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:56355 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbZCFWvI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2009 17:51:08 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n26Mma6Y008522
	for <linux-nfs@vger.kernel.org>; Fri, 6 Mar 2009 17:48:36 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n26Mp6hn181572
	for <linux-nfs@vger.kernel.org>; Fri, 6 Mar 2009 17:51:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n26Mp6BA009193
	for <linux-nfs@vger.kernel.org>; Fri, 6 Mar 2009 17:51:06 -0500
In-Reply-To: <1236370937.7244.52.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 6 Mar 2009, Trond Myklebust wrote:

>
> Does the attached patch help?
>
> Trond
>

Yes.  No corruption or issues on my large-ACL-list test system.
Thanks.

-Kevin

