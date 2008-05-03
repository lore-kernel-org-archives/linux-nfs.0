From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Sat, 03 May 2008 10:29:45 -0500
Message-ID: <481C84E9.3060602@gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>	 <20080421000214.GA5453@fieldses.org>	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>	 <481B316E.8090800@gmail.com>	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>	 <481B96D0.8010802@gmail.com> <24c1515f0805021554u483c471bm61cf3a6d8d434b45@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:42325 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870AbYECP3z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 May 2008 11:29:55 -0400
Received: by py-out-1112.google.com with SMTP id u52so567468pyb.10
        for <linux-nfs@vger.kernel.org>; Sat, 03 May 2008 08:29:54 -0700 (PDT)
In-Reply-To: <24c1515f0805021554u483c471bm61cf3a6d8d434b45-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Janne Karhunen wrote:
>
>>  I think you mis-understand our approach. With our patch, you do *not* need
>> to do anything if you have only one single (floating) interface to do nfs
>> export (and you can have the machine configured to use other hostname). The
>> statd's "my_name" is correctly filled (from kernel by our patch) - it is no
>> longer bound to 127.0.0.1.
>>     
>
> What happens when it fails over to node that has
> different name?  Mon_name in NOTIFY changes
> while address it's coming from does not. Which
> one should client believe - the address or the
> name?
>
> But OK, I probably need to dig out the patch to
> have a look.
>   
In the middle of re-doing our old patch (it should be very small this 
time, with Frank's patch already in mainline and Chuck taking over IPV6 
issues) so the logic can be clear. I also have a feel that you never 
look into "sm-notify" ? Get nfs-util git tree source and take a look at 
the "README" file in the top directory. Either Neil Brown or Steve 
Dickson had added a nice "DAEMON STARTUP ORDER" there. Basically the 
whole issue is a two-steps thing:

1. statd is the process responsible for recording client address into 
the nsm directory
2. sm-notify is the process responsible for notifying clients about 
server reboot activities.

The "sm-notify" design allows the flexibility of notifying clients with 
different cluster configurations, including yours. I think you already 
know this stuff very well... just do a "man sm-notify" ... it should 
clear up your confusions.

-- Wendy

