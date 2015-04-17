Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbbDQR40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Apr 2015 13:56:26 -0400
Message-ID: <55314947.7040706@RedHat.com>
Date: Fri, 17 Apr 2015 13:56:23 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>	<CAHQdGtSbn643SVAZ2Y_VzxmS_b-9=+pqPGWGoHtt25hpHpygLw@mail.gmail.com>	<CALs61uewbb28BcZ=d_qaYWtvUt5-xLGkn1uMXWhpjb_38f8ZtQ@mail.gmail.com>	<CAHQdGtSZcNj40YFYbKVL7M5ZtBgD278e6ifqM1hpb6BadU4j5A@mail.gmail.com>	<CALs61udukSrCsDYTyohSQdwbtcvvW672=+Qyit56iTE3qViSSw@mail.gmail.com>	<CALs61ue2HBxv6bJrGFoDj43vaYc_Jxf4-RJJ-vRBy9j2wn+tXA@mail.gmail.com> <CALs61ucnKU5J8NJ-unJNsYw_zsPb+_aYbLqndc0yEbtirixqhw@mail.gmail.com>
In-Reply-To: <CALs61ucnKU5J8NJ-unJNsYw_zsPb+_aYbLqndc0yEbtirixqhw@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/14/2015 03:39 PM, Gregory Boyce wrote:
> On Tue, Apr 14, 2015 at 3:37 PM, Gregory Boyce <gregory.boyce@gmail.com> wrote:
>> On Fri, Apr 10, 2015 at 3:04 PM Gregory Boyce <gregory.boyce@gmail.com>
>> wrote:
>>>
>>> On Fri, Apr 10, 2015 at 2:45 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>
>>>> No. You are not supposed to be able to work around security issues,
>>>> and it is indeed a security issue when a client gets a reply from an
>>>> IP address that it does not recognise as being the same as the one it
>>>> sent an RPC to.
>>>
>>> "Working around" security issues is a rather common and accepted
>>> practice when there are mitigating controls in place.  It's never a
>>> black and white world.
>>>
>>
>>
>> The attached patch was able to work around the issue for us until we can get
>> the filers working in a more expected manner.  I'm sending it along in case
>> anyone else can find a use for it, or if you want to apply it in order to
>> give people an option for cases like this.
> 
> Re-sending since Google Inbox likes to default to HTML e-mail.
> 
Could you please resend this patch using the proper Sign-off-by,
subject and description formats as describe in 
   https://www.kernel.org/doc/Documentation/SubmittingPatches

steved.
