Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63617 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaEAOQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 10:16:26 -0400
Received: by mail-pd0-f180.google.com with SMTP id x10so3169085pdj.25
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 07:16:25 -0700 (PDT)
References: <B05F63D2-8DB8-4FD3-92F9-C3A5B0A99D99@primarydata.com> <CAOhYWNKO1_x85nRP59xM1d6_SRg2Q+mtY2G08ZuBzncXgMHbHA@mail.gmail.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <CAOhYWNKO1_x85nRP59xM1d6_SRg2Q+mtY2G08ZuBzncXgMHbHA@mail.gmail.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <30596771-71A8-4FAA-A49E-3D8DE1238538@primarydata.com>
Cc: "nfsv4 list (nfsv4@ietf.org)" <nfsv4@ietf.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
From: Tom Haynes <thomas.haynes@primarydata.com>
Subject: Re: [nfsv4] Resolving the fate of FATTR4_CHANGE_SEC_LABEL
Date: Thu, 1 May 2014 07:16:24 -0700
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 1, 2014, at 7:07 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> On Sat, Apr 26, 2014 at 12:35 PM, Thomas Haynes
> <thomas.haynes@primarydata.com> wrote:
>> In my issues file, I have:
>> 
>> 4) Labeled NFS - FATTR4_CHANGE_SEC_LABEL - how big does it need to
>>   be?  Is seLinux going to support it?
>> 
>>   The Labeled NFS prototype in use does not currently support
>>   change_sec_label.
>> 
>>   In the past, we argued about how big it needed to be - we need
>>   to close down on this.
>> 
>> If we look at the current text in the NFSv4.2 draft, we see:
>> 
>>      The second change is to provide methods for the client to
>>      determine if the security label has changed. A client which
>>      needs to know if a label is going to change SHOULD request a
>>      delegation on that file. In order to change the security
>>      label, the server will have to recall all delegations. This
>>      will inform the client of the change. If a client wants to
>>      detect if the label has changed, it MAY use VERIFY and NVERIFY
>>      on FATTR4_CHANGE_SEC_LABEL to detect that the FATTR4_SEC_LABEL
>>      has been modified.
>> 
>> So the first question is do we need two methods for detecting that the label
>> has changed?
>> 
>> Section 8.3 of http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-21.txt
>> covers
>> how the client could use delegations to detect a label change.
>> 
>> To quote Trond out of context:
>> 
>> but that is the only option I can see for implementing a cache
>> consistency model for labels. Without it, the choices are:
>> 
>> 1) always fetch the label as part of every COMPOUND.
>> 2) assume the label never changes on the server.
>> 
>> The main use cases that have been presented for Labeled NFS on Linux
>> would tend to push me towards door number 2, Monty please...
> 
> In principle, the label should only rarely change, but they do change
> for various reasons (admin goofs and forgets to set the label in the
> first place and then needs to fix it, SELinux policy changes mandate
> that a label changes from some type to another, etc). I think assuming
> that the label never changes would be very problematic. If the label
> does change, you'd basically need to remount on the client.
> 
> That said, I don't see any real need to treat the label differently
> from any other attribute. If you're trying to use these for
> client-side enforcement, then you just need to be aware that you can
> race with label changes on the server.
> 
>> 
>> So a client could assume that the label never changes the majority
>> of the time. Once it decides it does need to start checking for a change
>> in the label, it can get a delegation.
>> 
>> If we do need the attribute, what size does it need to be?
>> 
>> There has been mention of it being a hash or a timestamp.
> 
> I guess part of the problem is that we're trying to do client-side
> enforcement with these labels, and that's always going to be
> difficult. The server should really be what's doing the enforcement.
> Once we have that, we can just treat the security label like any other
> attribute and not worry about cache coherency.

So are you advocating one of:

1) No detection of change
2) Client gets a delegation
3) Use the new attribute

FWIW, I like #2. :-)


