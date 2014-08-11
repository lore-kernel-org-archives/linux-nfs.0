Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:54269 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbaHKSXi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 14:23:38 -0400
Received: by mail-ie0-f169.google.com with SMTP id rd18so10343160iec.14
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 11:23:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAd7aua8+U=eFZUFhjp8gcnYv9BkvjOgSbLJbGp_Qg9O5cHH5w@mail.gmail.com>
References: <CAAd7aua8+U=eFZUFhjp8gcnYv9BkvjOgSbLJbGp_Qg9O5cHH5w@mail.gmail.com>
Date: Mon, 11 Aug 2014 13:23:38 -0500
Message-ID: <CAAd7auZOmk4_tR0WnqFCbv3CSLF=BXoQjtdsQZaB0dgoOYNREw@mail.gmail.com>
Subject: Fwd: question re: NO_AUTH_DATA_REQUIRED
From: Ben H <bhendin@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First off, apologies if this is not the correct list.
I saw questions like this on the old nfsv4@linux-nfs.org list, and
believe that this replaces that.
Please direct me to a more appropriate resource if available.
If I'm in the right place, I'm looking for some schooling...

I have been working with NFSv4 sec=krb5 and early on ran into the PAC
issue described nebulously throughout various resources on the web.

When working with AD users who are in multiple groups (in my
experiments, seems to be approximately 20) I have to set
NO_AUTH_DATA_REQUIRED on the userAccountControl of my NFS server
principal so that the PAC is not sent and the TGS-REQ can occur over
UDP.

What I cannot find an answer for is why/where exactly is this
limitation introduced?
Kerberos can deal with the larger packets via TCP, and some Kerberos
implementation may enforce TCP even on smaller packets.

(1) Will NFSv4 have an issue with pure TCP, or is there an internal
limitation (and if so what) within the NFS code that prohibits the
larger PAC buffer (regardless of how it was delivered) from working?

It seems this issue has been around for quite a while, yet the errors
given on such an event are relatively obtuse:

WARNING: Failed to create krb5 context for user with uid 402135588 for
server spp-vp-master01.spptech.com
WARNING: Failed to create krb5 context for user with uid 402135588 for
server spp-vp-master01.spptech.com
doing error downcall

(2) Is there a level of debugging that would have provided me more
data about the particular event?

My second issue is in trying to understand what possible drawbacks
might exist with setting NO_AUTH_DATA_REQUIRED.
I previously have not used NO_AUTH_DATA_REQUIRED, and when I first
read http://support.microsoft.com/kb/832572, I was under the
impression that this was something that you would set on a user's
account to prohibit the PAC from being sent.
For instance, if "jsmith" is having problems accessing a service, then
you would set NO_AUTH_DATA_REQUIRED on "jsmith" directly.
This of course, would be very problematic since jsmith requires his
PAC for logging into Windows systems or for access to other services
which might use his PAC for authorizations.
Although, I believe the NO_AUTH_DATA_REQUIRED does not affect getting
a PAC in an AS-REP, only in a TGS-REP(?)  Still, it would prohibit
jsmith from obtaining correct authorizations to Windows services.

In working with NFSv4 it is apparent that you only need to set
NO_AUTH_DATA_REQUIRED on the nfs/principal account whether that is a
user account or the computer account (when joined to AD via Samba or
3rd party tools).
It also became clear that even though configuration using a computer
account (when available) is generally easier, this might cause
problems is the computer account is used for multiple services, some
which might require a PAC.

Therefore, creating a separate nfs/userprincipal and enabling
NO_AUTH_DATA_REQUIRED appears to solve the issue.

My assumption is that setting NO_AUTH_DATA_REQUIRED works this way:
a) When set on a user account is prevents the user's PAC from being
added to *any service ticket requested*
b) When set on a service account if prevents PACs from *all users
being to service tickets requested for itself*

(3) Can someone confirm if this is correct?

(4) My overarching question on this is "are we loosing anything re:
sec=krb5 without a PAC being delivered in the service ticket to the
NFS server?"

Once the NFSv4 server has authenticated our user identity us based on
our service ticket, are authorizations for the data being done solely
on UID/GID mappings?
If all my groups are defined in AD, and the NFS client and Server
resolve those groups, I assume that is enough?
As long as the client is aware of all the user groups (i.e. "id" shows
all the proper groups) then I should be able to access the files?

TIA for all help.
