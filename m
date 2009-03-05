From: "Kevin W. Rudd" <solgato@us.ibm.com>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Thu, 5 Mar 2009 11:49:46 -0800 (PST)
Message-ID: <alpine.LFD.1.10.0903051135040.3949@w-kevinr.beaverton.ibm.com>
References: <49760685.4030409@redhat.com>  <1232475301.7055.14.camel@heimdal.trondhjem.org>  <alpine.LFD.1.10.0903050829420.3949@w-kevinr.beaverton.ibm.com> <1236279188.13361.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47303 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbZCETtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 14:49:52 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n25JlBnP014647
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 14:47:11 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n25JnorU194528
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 14:49:50 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n25JnnT7002790
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 14:49:50 -0500
In-Reply-To: <1236279188.13361.30.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 5 Mar 2009, Trond Myklebust wrote:

> Going over that particular procedure reveals a number of bugs that all
> should be fixed.

So true ;-)

> Trying to estimate how many bytes are free in the header is _WRONG_.
> That memory is allocated with certain assumptions, which are set in the
> definition of ACL3_setaclargs_sz. In this case, the assumptions appear
> to be that we will fit a maximum of 5 ACEs in the header.
> IOW: the real fix for your corruption problem is simply to set
> len_in_head to 2*(2+5*3). Currently, the patch supplied by Sachin will
> always set it to zero.

Does setting len_in_head to 2*(2+5*3) take into account the
header space already consumed?  The initial patch was just a
quick-n-dirty way of making sure we didn't overwrite the initial
buffer, and a mechanism for generating some discussion around the
other deficiencies in this procedure.  I'll take the blame for
it being a quick hack to simply take the heat off for a critical
customer situation :)

> Secondly, doing page allocation in the XDR routine is _WRONG_. For one
> thing, look at the major memory leak which happens if the client needs
> to resend the request (which can happen every now and again due to a
> dropped tcp connection, or all the time due to UDP retransmits).
> Those pages should have been allocated in nfs3_proc_getacl(), and indeed
> that is where the wretched things are freed.

That's an issue I hadn't noticed, but this isn't really my area of
expertice.  Thanks for taking a closer look at this area of code.

-Kevin
