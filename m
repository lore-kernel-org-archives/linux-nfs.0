Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbbEGNsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 09:48:18 -0400
Message-ID: <554B6D1F.2040207@RedHat.com>
Date: Thu, 07 May 2015 09:48:15 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-utils: Allow users to disable mount option rewriting
 via norewriteopts mount option
References: <alpine.DEB.2.10.1504201417410.5338@valhalla.home>	<554A7626.1050709@RedHat.com> <CALs61uevioa8FgEbCuTO2JA+74mnH_PCAPUzpLfSzGJ-68729w@mail.gmail.com>
In-Reply-To: <CALs61uevioa8FgEbCuTO2JA+74mnH_PCAPUzpLfSzGJ-68729w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/06/2015 04:28 PM, Gregory Boyce wrote:
> On Wed, May 6, 2015 at 4:14 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>> On 04/20/2015 02:18 PM, Gregory Boyce wrote:
>>> Allow users to disable mount option rewriting via norewriteopts mount option.
>>> This was required in our case in order to allow mounting a filer which inappropriately responded via the wrong interface.
>>>
>>> Signed-off-by: Gregory Boyce <gregory.boyce@gmail.com>
>> Again... This is fixing a filer bug, correct?
>>
>> We generally don't do that...
>>
>> steved.
> 
> This is working around a server bug on the client side, yes.
> 
That's tough... We generally don't do that because its becomes
a very slippy slope very quickly.... esp with adding a undocumented
mount flag we are going have to support forever...

This is something I just don't think is the right thing to do
so I'm going to NAK this patch. 

steved.


 
