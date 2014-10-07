Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail03v-smtp01.fnal.gov ([131.225.199.28]:21847 "EHLO
	ex-smtp.fnal.gov" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752186AbaJGCxL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 22:53:11 -0400
From: "Andrew J. Romero" <romero@fnal.gov>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Michael K. Rosier" <mrosier@fnal.gov>, Briant S Lawson <blawson@fnal.gov>,
        Joseph W Klemencic <jklemenc@fnal.gov>,
        Lynn A Garren <garren@fnal.gov>
Subject: Linux NFSv4 security issue:  client presents wrong user's
 credentials to NFS server
Date: Tue, 7 Oct 2014 02:47:48 +0000
Message-ID: <ACC0FF8A2EDF4D42AC55DCCCC7FC1E0E30845CB8@MAIL01.fnal.gov>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

It is common in certain cases for
a Linux workstation administrator to 
create a shared account with a 
corresponding .k5login file.

Kerberos principal strings for users
are added to the .k5login and the corresponding
users can logon as the local shared account using
their Kerberos credentials.

Once logged on to the workstation, the user's
local identity (local to the workstation) is
the UID of the local shared account; however,
when accessing kerberized resources external
to the workstation (for example NFSv4 volumes),
the user's identity is expected to be the 
individual user's kerberos identity.

I am seeing the following serious security issue:

If N users (user1@REALM , user2@REALM ...userN@REALM)
(who are listed  sharusr's .k5login) all logon to 
workstation1 as sharusr and are all running sessions
simultaneously, then, the GSS Context / kerberos credentials 
stored in and used by the NFS-client kernel code when
processing NFS requests on behalf of a user,
will be correct for 1 user and incorrect for N-1 users.

Each of the N-1 users will not be able to 
access NFS server resources that only they have been 
granted access to; but, they will be able
to access all NFS resources that the 1  user
has been granted access to. (even if their
kerberos identity has not been granted access).

Even after each of the N-1 users destroys their credentials
they still retain access to all NFS resources 
that the 1 user has been granted access to.
Access will not be denied until the 1 user also destroys
his / her credentials.

It is my understanding that the RPC GSS kernel module 
on an NFS client system, keeps a GSS security context 
(copy of a user's credentials) that it uses when it 
communicates with the NFS server on the user's behalf. 

I believe that the kernel security context
relates back to the user mode process solely by UID number.

Would adding session ID to the relation resolve the issue ?
Each Session for each user would then have a unique tuple
(UID,SessionID) that would map to the *correct* GSS Security
context in the kernel.

Thanks

Andy Romero
romero@fnal.gov
NAS / SAN Administrator, Fermilab

