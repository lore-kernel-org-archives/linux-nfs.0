Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38428 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330AbbJGPqC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 11:46:02 -0400
Received: by igxx6 with SMTP id x6so17607833igx.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 08:46:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56153576.1090209@mit.edu>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com>
	<FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com>
	<5612CB0F.5040501@mit.edu>
	<A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com>
	<5612D73F.8020605@mit.edu>
	<9ED9C3B6-A0D0-411F-AB95-77CB1E8AA097@netapp.com>
	<alpine.GSO.1.10.1510051952080.26829@multics.mit.edu>
	<9E0A46D0-6A66-47A2-848C-81A13EF20A52@netapp.com>
	<EEF67DC8-C71A-4914-B614-EBEC63404F0B@netapp.com>
	<56152FF4.8050705@mit.edu>
	<16B417DB-F019-4654-8B4E-7C4C3AF1487D@netapp.com>
	<56153576.1090209@mit.edu>
Date: Wed, 7 Oct 2015 11:46:01 -0400
Message-ID: <CAN-5tyE8pWdJ=zHW+O8R1bvWFHrHHi029xvXJAo0YJfDX3zpjw@mail.gmail.com>
Subject: Re: Gss context refresh failure due to clock skew
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Greg Hudson <ghudson@mit.edu>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "krbdev@mit.edu" <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 11:08 AM, Greg Hudson <ghudson@mit.edu> wrote:
> On 10/07/2015 11:00 AM, Adamson, Andy wrote:
>> —— from the ticket: ——
>>
>> This unnecessarily strict check causes a particularly bad experience
>> when (a) the client's clock is slightly ahead of the server's clock,
>> and (b) the maximum service ticket lifetime is lower than the maximum
>> TGT lifetime.
>>
>> —— ——
>> I think both a) and b) are incorrect.
>>
>> for a) you got it backwards. this occurs when the server clock is ahead of the client clock.
>
> Yes, I did write the wrong thing there; I will follow up on that.
>
>> for b) the relationship between the TGT lifetime and the service ticket lifetime is irrelevant. Only the service ticket lifetime has any effect as the client will use a valid service ticket to construct an RPCSEC_GSS_INIT request irregardless of the TGT lifetime value.
>
> I will try one more time to communicate what I mean:
>
> * If the service ticket end time is less than the TGT end time, then
> gss_init_sec_context() fails during the clock skew window, and starts
> succeeding again afterwards.
>
> * If the service ticket and TGT have both expired (according to the
> server), then gss_init_sec_context() fails, and keeps failing
> afterwards, unless there is some out-of-band agent refreshing expired TGTs.
>
> Put another way: we expect authentications to start failing around the
> time the TGT expires.  We do not expect authentications to start failing
> around the time a service ticket expires, if the TGT is still valid.

Why not? This is not what should happen according to the theory of
Kerberos protocol. Let's use slightly generic terms, TGT is a
credential that proves client's identity to the KDC. TGT or it's
lifetime has no relevance in the context of authentication between the
client and a kerberized service, in this case an NFS server. Then a
service ticket is a credential that is used to prove client's identity
to the NFS server. The lifetime of the NFS service ticket should be
allowed to be valid within some configurable clock skew.

> That is what I refer to as a "particularly" bad experience.
>
> If that isn't clear, perhaps we should ignore this as a moot point; it
> doesn't really affect how we plan to change the krb5 code.
> _______________________________________________
> krbdev mailing list             krbdev@mit.edu
> https://mailman.mit.edu/mailman/listinfo/krbdev
