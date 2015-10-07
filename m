Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-3.mit.edu ([18.9.25.14]:52555 "EHLO
	dmz-mailsec-scanner-3.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752402AbbJGOuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 10:50:18 -0400
Subject: Re: Gss context refresh failure due to clock skew
To: "Adamson, Andy" <William.Adamson@netapp.com>,
        Benjamin Kaduk <kaduk@mit.edu>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com>
 <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com> <5612CB0F.5040501@mit.edu>
 <A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com> <5612D73F.8020605@mit.edu>
 <9ED9C3B6-A0D0-411F-AB95-77CB1E8AA097@netapp.com>
 <alpine.GSO.1.10.1510051952080.26829@multics.mit.edu>
 <9E0A46D0-6A66-47A2-848C-81A13EF20A52@netapp.com>
 <EEF67DC8-C71A-4914-B614-EBEC63404F0B@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "krbdev@mit.edu" <krbdev@mit.edu>
From: Greg Hudson <ghudson@mit.edu>
Message-ID: <56152FF4.8050705@mit.edu>
Date: Wed, 7 Oct 2015 10:45:08 -0400
MIME-Version: 1.0
In-Reply-To: <EEF67DC8-C71A-4914-B614-EBEC63404F0B@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/07/2015 09:22 AM, Adamson, Andy wrote:
> Actually, setting the service ticket lifetime to be equal to (or greater than if this is possible) the TGT lifetime will not help. Just as in the example I sent, the application will get permission denied during the time difference between the client and server clock.

That is expected.  What is not expected, in this variant, is that
gss_init_sec_context() will succeed by itself once the client believes
the TGT and service ticket to have expired.  Apologies for any
miscommunication on this point.

There may be something in the calling code which refreshes the TGT in
this situation.  If so, then to fully understand the scenario, we need
to know how the calling code decides when to refresh the TGT.

I opened a ticket about this issue here:

    http://krbdev.mit.edu/rt/Ticket/Display.html?id=8268
