Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760636Ab3DJOyH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 10:54:07 -0400
Message-ID: <51657D07.8030506@RedHat.com>
Date: Wed, 10 Apr 2013 10:53:59 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, jlayton@redhat.com
Subject: Re: [PATCH 1/2] Avoid reverse resolution for server name
References: <515B2F8D.3030302@RedHat.com> <1364931149-18484-2-git-send-email-simo@redhat.com> <5162C8A5.4030307@RedHat.com> <1365430116.20560.6.camel@willson.li.ssimo.org> <51644CC5.3070609@RedHat.com> <1365528308.20560.42.camel@willson.li.ssimo.org> <5164514A.7020606@RedHat.com> <20130409185445.GA3800@fieldses.org> <51646838.3050209@RedHat.com> <20130409192259.GD3800@fieldses.org>
In-Reply-To: <20130409192259.GD3800@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/04/13 15:22, J. Bruce Fields wrote:
> On Tue, Apr 09, 2013 at 03:12:56PM -0400, Steve Dickson wrote:
>>
>>
>> On 09/04/13 14:54, J. Bruce Fields wrote:
>>> Argh, no, one away or another the default needs to be to not do the PTR
>>> lookup.
>> Fine... 
>>  
>>>
>>> The transition Simo's using was Jeff's suggestion.  Let's just stick to
>>> that if we don't have a good reason.
>> Yeah... I would like to avoid adding to flags... I don't think both are 
>> needed.
> 
> So, no flags.
> 
>>> (But I don't have strong opinions about how to do it either.  I'd
>>> actually be OK with being harsh and just switching to the new behavior
>>> without any option.)
>> My crutch is I'm not a big DNS guy so I'm not sure how much breakage 
>> would occur... So I would rather be on the safe side and give people
>> a way to go back... 
> 
> So, yes to flags.  I'm confused!
Join the club! ;-)

> 
> I guess we can be moderately harsh: switch to the new default and
> provide only a flag to restore the old default for whoever wants it, but
> not a flag to specify the new default.  Is that what you mean?
Yes... This makes sense to me...

steved.
