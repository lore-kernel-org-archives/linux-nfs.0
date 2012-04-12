Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752Ab2DLOn3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Apr 2012 10:43:29 -0400
Message-ID: <4F86EA08.5000308@RedHat.com>
Date: Thu, 12 Apr 2012 10:43:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Michael Weiser <M.Weiser@science-computing.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
References: <20120312200221.GS29573@science-computing.de> <CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com> <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de> <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com> <20120313144214.GB16920@science-computing.de> <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com> <20120314134829.GA943@science-computing.de> <20120319130043.GG9020@science-computing.de> <4F686996.5050108@RedHat.com> <20120320174418.GL24828@science-computing.de> <20120329140226.GB1362@science-computing.de>
In-Reply-To: <20120329140226.GB1362@science-computing.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/29/2012 10:02 AM, Michael Weiser wrote:
> Hi Steve,
> 
> On Tue, Mar 20, 2012 at 06:44:18PM +0100, Michael Weiser wrote:
> 
>>>> If nobody objects, I'd resubmit my patch to gssd with some cleanup and
>>>> documentation.\
>>> No, Please do...
>> Here's the patch. Is there any special procedure to follow to get it
>> committed?
> 
> How do I go about getting this committed?
My bad... I'm looking into this now....

> 
>> I just noticed that while the code bits are optional based on
>> HAVE_SET_ALLOWABLE_ENCTYPES, the man page part isn't. I've got no idea,
>> how to go about that.
I'm think we should remove all those defines and have the code enabled
by default. The main reason is defines like that just clutter up the 
code, plus there would be a needed for another configuration flag
which I think is a bit over kill... 

steved.
