Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:64527 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227AbbJGPIp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 11:08:45 -0400
Subject: Re: Gss context refresh failure due to clock skew
To: "Adamson, Andy" <William.Adamson@netapp.com>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com>
 <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com> <5612CB0F.5040501@mit.edu>
 <A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com> <5612D73F.8020605@mit.edu>
 <9ED9C3B6-A0D0-411F-AB95-77CB1E8AA097@netapp.com>
 <alpine.GSO.1.10.1510051952080.26829@multics.mit.edu>
 <9E0A46D0-6A66-47A2-848C-81A13EF20A52@netapp.com>
 <EEF67DC8-C71A-4914-B614-EBEC63404F0B@netapp.com> <56152FF4.8050705@mit.edu>
 <16B417DB-F019-4654-8B4E-7C4C3AF1487D@netapp.com>
Cc: Benjamin Kaduk <kaduk@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "krbdev@mit.edu" <krbdev@mit.edu>
From: Greg Hudson <ghudson@mit.edu>
Message-ID: <56153576.1090209@mit.edu>
Date: Wed, 7 Oct 2015 11:08:38 -0400
MIME-Version: 1.0
In-Reply-To: <16B417DB-F019-4654-8B4E-7C4C3AF1487D@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/07/2015 11:00 AM, Adamson, Andy wrote:
> —— from the ticket: —— 
> 
> This unnecessarily strict check causes a particularly bad experience
> when (a) the client's clock is slightly ahead of the server's clock,
> and (b) the maximum service ticket lifetime is lower than the maximum
> TGT lifetime. 
> 
> —— —— 
> I think both a) and b) are incorrect.
> 
> for a) you got it backwards. this occurs when the server clock is ahead of the client clock.

Yes, I did write the wrong thing there; I will follow up on that.

> for b) the relationship between the TGT lifetime and the service ticket lifetime is irrelevant. Only the service ticket lifetime has any effect as the client will use a valid service ticket to construct an RPCSEC_GSS_INIT request irregardless of the TGT lifetime value.

I will try one more time to communicate what I mean:

* If the service ticket end time is less than the TGT end time, then
gss_init_sec_context() fails during the clock skew window, and starts
succeeding again afterwards.

* If the service ticket and TGT have both expired (according to the
server), then gss_init_sec_context() fails, and keeps failing
afterwards, unless there is some out-of-band agent refreshing expired TGTs.

Put another way: we expect authentications to start failing around the
time the TGT expires.  We do not expect authentications to start failing
around the time a service ticket expires, if the TGT is still valid.
That is what I refer to as a "particularly" bad experience.

If that isn't clear, perhaps we should ignore this as a moot point; it
doesn't really affect how we plan to change the krb5 code.
