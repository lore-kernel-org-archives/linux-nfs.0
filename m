From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 05 May 2008 12:00:00 -0400
Message-ID: <481F2F00.8000303@gmail.com>
References: <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>	 <481B96D0.8010802@gmail.com>	 <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>	 <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com>	 <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>	 <481F2600.20501@gmail.com>	 <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com>	 <20080505152519.GE8259@fieldses.org> <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43469 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834AbYEEP5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:57:48 -0400
In-Reply-To: <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Janne Karhunen wrote:
> On Mon, May 5, 2008 at 11:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
>   
>>  > As statd runs this directly and reads name for -v from
>>  > MY_NAME,
>>
>>  Nope; see the -L option to statd.
>>     
>
> So the let the user worry approach. Statd does not
> notify anyone and user is supposed to do it with
> sm-notify manually. This will work, but -n looks
> cleaner me..
>
>   

Or we can do this ...
If user specified "statd -n", we run "sm-notify -v" command for them ? 
So we don't need to fork the code but also keep someone happy ?

Give me one day to see whether it is doable ?

-- Wendy
