Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab0K3Pg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 10:36:29 -0500
Message-ID: <4CF519F2.8080900@RedHat.com>
Date: Tue, 30 Nov 2010 10:36:18 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Spelic <spelic@shiftmail.org>,
        linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
References: <4CF3ED05.3070401@shiftmail.org>	 <1291054975.12784.17.camel@heimdal.trondhjem.org>	 <4CF3F326.4060608@shiftmail.org>  <20101129190122.GA31843@fieldses.org> <1291057747.12784.38.camel@heimdal.trondhjem.org>
In-Reply-To: <1291057747.12784.38.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 11/29/2010 02:09 PM, Trond Myklebust wrote:
> On Mon, 2010-11-29 at 14:01 -0500, J. Bruce Fields wrote:
>> On Mon, Nov 29, 2010 at 07:38:30PM +0100, Spelic wrote:
>>> On 11/29/2010 07:22 PM, Trond Myklebust wrote:
>>>> On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
>>>> No. That is not allowed by the spec.
>>>>
>>>> Trond
>>>
>>> Too bad!! :-((
>>> Was that spec decision really wise? :-/
>>>
>>>
>>> BTW:
>>> I've just noticed two discussions dated a few months ago in this ML
>>> regarding this.
>>> the thread named 'numeric UIDs'
>>
>> There's also a reference to the spec language there--we'd be violating a
>> "SHOULD", but I think it would be acceptable if it smooths the v3->v4
>> upgrade path for users in your situation.
>>
>> I think steved's changes still need to be ported to libnfsidmap?
> 
> I don't see how steved's changes will fix this problem. If the client
> has a mapping, it will (MUST) send the mapped uid/gid and the server
> still has to make sense of that. Ditto if the server has a mapping, and
> the client does not.
I actually thought it did... 

Now that the libnfsidmap maintainership has been handed over to me 
and I'm about to enable the new nfsidmapper when I commit the 
"libnfsidmap: Add numerical string translation" patch... Its 
probably time I take a second look at those patches to see
if we can ease some of this pain...

steved.
