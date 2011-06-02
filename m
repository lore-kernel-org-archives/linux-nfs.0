Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38508 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab1FBOgW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 10:36:22 -0400
Message-ID: <4DE79FDD.90104@candelatech.com>
Date: Thu, 02 Jun 2011 07:36:13 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Ranjith Kumar <ranjitbat@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Bind NFS Services to specific IP address
References: <BANLkTimiv7LXs9Jo7ABA5Mc+0Vn+Q1UEug@mail.gmail.com> <BANLkTimH+UPaKbzDnWE4NAPF=b=f+x5aag@mail.gmail.com> <A842031D-AB09-4CCC-B338-5CA8AD5534C9@oracle.com>
In-Reply-To: <A842031D-AB09-4CCC-B338-5CA8AD5534C9@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/02/2011 05:53 AM, Chuck Lever wrote:
>
> On Jun 2, 2011, at 4:01 AM, Ranjith Kumar wrote:
>
>> Hi,
>>
>> How you bind the nfs services to specific IP address?
>
> As far as I know, the kernel NFSD does not allow binding to any other address than ADDR_ANY.

I have patches to do the client-side, at least....  Never had any luck getting
them accepted upstream though.

Ben

>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
