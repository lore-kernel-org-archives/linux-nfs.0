Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38059 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbbEFU2I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 16:28:08 -0400
Received: by igbhj9 with SMTP id hj9so27625838igb.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 13:28:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <554A7626.1050709@RedHat.com>
References: <alpine.DEB.2.10.1504201417410.5338@valhalla.home>
	<554A7626.1050709@RedHat.com>
Date: Wed, 6 May 2015 16:28:07 -0400
Message-ID: <CALs61uevioa8FgEbCuTO2JA+74mnH_PCAPUzpLfSzGJ-68729w@mail.gmail.com>
Subject: Re: [PATCH] nfs-utils: Allow users to disable mount option rewriting
 via norewriteopts mount option
From: Gregory Boyce <gregory.boyce@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 6, 2015 at 4:14 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 04/20/2015 02:18 PM, Gregory Boyce wrote:
>> Allow users to disable mount option rewriting via norewriteopts mount option.
>> This was required in our case in order to allow mounting a filer which inappropriately responded via the wrong interface.
>>
>> Signed-off-by: Gregory Boyce <gregory.boyce@gmail.com>
> Again... This is fixing a filer bug, correct?
>
> We generally don't do that...
>
> steved.

This is working around a server bug on the client side, yes.

-- 
Greg
