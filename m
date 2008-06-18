From: Andreas Westin <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org>
Subject: Re: cross-compile nfs-utils
Date: Wed, 18 Jun 2008 14:19:45 +0200
Message-ID: <374421031ffa66fdc0592531eb8a687c@forsaken.se>
References: <6043ada4386b12792b4c0d0b64a30c6b@forsaken.se> <4d569c330806171052v1fd4bc95o7d85d7a3263c33da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:40298 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbYFRMT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 08:19:28 -0400
In-Reply-To: <4d569c330806171052v1fd4bc95o7d85d7a3263c33da-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Ok, I'll look into it. Need to learn some automake first :)

/Andreas


On Tue, 17 Jun 2008 13:52:13 -0400, "Kevin Coffman" <kwc@umich.edu> wrote:
> Hi,
> It would be easiest (and quicker to make it into the distribution) if
> you could supply a patch that fixes this for the cross-compile case.
> I, for one, don't do cross-compiling and find it difficult to test
> these kind of things.
> 
> K.C.
> 
> On Tue, Jun 17, 2008 at 8:43 AM, Andreas Westin <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org>
> wrote:
>> Hello,
>>
>> When you cross-compile nfs-utils 1.1.2 for ARM, locktest and rpcdebug
>> fails because they don't use the CFLAGS_FOR_BUILD and
>> CPPFLAGS_FOR_BUILD. This becomes a problem when you use flags which
>> the host compiler doesn't support such as -mthumb.
>>
>> /Andreas

