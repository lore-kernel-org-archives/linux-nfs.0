Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-5.mit.edu ([18.7.68.34]:42689 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738AbbJETPV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 15:15:21 -0400
Subject: Re: Fwd: Gss context refresh failure due to clock skew
To: "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com>
 <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com>
Cc: "krbdev@mit.edu" <krbdev@mit.edu>
From: Greg Hudson <ghudson@mit.edu>
Message-ID: <5612CB0F.5040501@mit.edu>
Date: Mon, 5 Oct 2015 15:10:07 -0400
MIME-Version: 1.0
In-Reply-To: <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay; Andy's mail got stuck in the krbdev moderation
queue by mistake.

On 10/01/2015 05:30 PM, Adamson, Andy wrote:
> The situation occurs as follows.

I am a little bit confused by this description because of terminology
issues.  In your description, you appear to use the phrase "TGS" to
refer to service tickets (i.e. tickets whose service principal is
nfs/server.name), but I can't be sure.  The actual meaning of "TGS" is
"ticket-granting service," i.e. the KDC service whose principal name is
krbtgt/REALM.

> 2) For convenience, I set the TGS lifetimes to be as short as possible, 10 minutes for Win2008R2 AD which I test with.

Are you setting the maximum lifetime for nfs/server.name tickets to 10
minutes, but still allowing ticket-granting tickets to have a lifetime
of multiple hours?

>> 12) Wait until the client clock is past the server TGS expiry time
>> 13) re-try the mkdir - it succeeds after a successful GSS INIT NULL call exchange for both servers.

If I understand correctly, this request succeeds because
krb5_get_credentials() ignores the expired cached service ticket and
makes a TGS request for a new service ticket.  The cache now contains:

* A ticket for krbtgt/REALM with hours remaining
* A ticket for nfs/server.name which expired recently
* Another ticket for nfs/server.name which expires in ten minutes

Is that correct?

> Shouldn’t these refresh calls succeed? Isn’t the Kerberos clock skew supposed to handle this situation?

I think this case doesn't arise often because people don't often set
maximum service ticket lifetimes to be shorter than maximum TGT
lifetimes.  If the TGT itself has expired or is about to expire, some
out-of-band agent needs to refresh the TGT somehow, and it doesn't
matter all that much whether the failure comes from the client or the
server.

That said, your scenario should work, and it doesn't.  The primary cause
is an explicit check added to the krb5 mech's gss_accept_sec_context()
implementation in 1996 (before the MIT krb5 1.0 release), which checks
the ticket endtime with no allowance for clock skew.  I don't know
precisely why the check was added, but my guess it is for the
computation of the context validity lifetime; it would make no sense to
tell the application "the authentication succeeded and the resulting
context is valid for the next -3 minutes."

Perhaps a better choice would be to remove this check, and instead add
the clock skew to the validity lifetime of GSS krb5 acceptor contexts.
