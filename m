From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 07/11] nfs-utils: convert nfssvc_setfds to use getaddrinfo
Date: Sat, 01 Aug 2009 09:08:41 -0400
Message-ID: <4A743E59.8080703@RedHat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>	<1244484044-21355-8-git-send-email-jlayton@redhat.com>	<4A742896.1010005@RedHat.com> <20090801084501.6fee9d06@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42354 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbZHANMG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Aug 2009 09:12:06 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n71DBua8011768
	for <linux-nfs@vger.kernel.org>; Sat, 1 Aug 2009 09:12:01 -0400
In-Reply-To: <20090801084501.6fee9d06-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/2009 08:45 AM, Jeff Layton wrote:
> On Sat, 01 Aug 2009 07:35:50 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 06/08/2009 02:00 PM, Jeff Layton wrote:
>>>  static void
>>>  nfssvc_versbits(unsigned int ctlbits, int minorvers4)
>>>  {
>>> @@ -180,8 +246,11 @@ nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
>>>  	 * the ports get registered with portmap against correct
>>>  	 * versions
>>>  	 */
>>> -	nfssvc_versbits(versbits, minorvers4);
>>> -	nfssvc_setfds(port, protobits, haddr);
>>> +	if (!nfssvc_inuse()) {
>>> +		nfssvc_versbits(versbits, minorvers4);
>>> +		snprintf(buf, sizeof(buf), "%d", port);
>>> +		nfssvc_set_sockets(AF_INET, protobits, haddr, portstr);
>> portstr is not defined here.... and as far as I can tell its not
>> defined in any of the next 3 patches either... 
>>
>> What am I missing or it is missing?
>>
>> steved.
>>
> 
> You're right. That's a spot that I missed when I converted that code to
> use the static buffer instead of allocating a memory all over the
> place. That "portstr" should be "buf" instead.
> 
> The good news is that a later patch removes that entire if statement.
> The final outcome of the set shouldn't be affected by this. Would you
> like me to respin that patch and the later one that removes that chunk
> of code?
> 
No Respin will be necessary... But in the future please make sure
each patch will compile and is somewhat functional... Also, if
possible, please order patches so if new code is added and then 
later removed, that code is never seen at all... 

steved.
   
