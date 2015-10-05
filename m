Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-5.mit.edu ([18.7.68.34]:44793 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbbJEUCV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 16:02:21 -0400
Subject: Re: Gss context refresh failure due to clock skew
To: "Adamson, Andy" <William.Adamson@netapp.com>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com>
 <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com> <5612CB0F.5040501@mit.edu>
 <A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "krbdev@mit.edu" <krbdev@mit.edu>
From: Greg Hudson <ghudson@mit.edu>
Message-ID: <5612D73F.8020605@mit.edu>
Date: Mon, 5 Oct 2015 16:02:07 -0400
MIME-Version: 1.0
In-Reply-To: <A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/05/2015 03:35 PM, Adamson, Andy wrote:
>> I think this case doesn't arise often because people don't often set
>> maximum service ticket lifetimes to be shorter than maximum TGT
>> lifetimes.  
> 
> Not the cause of the issue. The service ticket lifetime of 10 minutes is just there for testing this issue as I needed to wait until the service ticket had ‘expired’ on the server - but not yet on the client.
> 
> We see this issue all the time in NetApp QA as we run mutiple day heavy IO tests against a kerberos mount. If the server clock is ahead of the client clock, permission denied errors stop the test as the first service ticket “expires” on the server but not on the client.

If the issue is not caused by short-lifetime service principals, then
the test scenario you described isn't representative of the real
scenario.  To reproduce the problem as it manifests in your IO tests,
you will need to adjust the TGT lifetime down to ten minutes as well as
the nfs/server lifetime.

>> If the TGT itself has expired or is about to expire, some
>> out-of-band agent needs to refresh the TGT somehow, and it doesn't
>> matter all that much whether the failure comes from the client or the
>> server.
> 
> I thought that having a keytab entry and a renewable TGT was enough.

I'm not sure why you would do both of these; if you're getting initial
creds with a keytab, there is no need to muck around with ticket renewal.

Anyway, gss_init_sec_context() never renews tickets, and only gets
tickets from a keytab when a client keytab is configured (new in 1.11).
 When tickets are obtained using a client keytab, they are refreshed
from the keytab when they are halfway to expiring, so this clock skew
issue should not arise, so I don't think that feature is being used.

It is possible that the NFS client code has its own separate logic for
obtaining new tickets using a keytab.  If so, we need to understand how
it works.  It's possible (though unlikely) that changing the behavior of
gss_accept_sec_context() wouldn't be sufficient by itself.
