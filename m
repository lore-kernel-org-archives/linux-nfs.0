Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36749 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752426AbdCJCVz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 21:21:55 -0500
Received: by mail-io0-f172.google.com with SMTP id l7so40492231ioe.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 18:21:54 -0800 (PST)
MIME-Version: 1.0
From: Andre Caldas <andre.em.caldas@gmail.com>
Date: Thu, 9 Mar 2017 23:21:33 -0300
Message-ID: <CADVh14Xvx5RE_88UYMfpCK9AxL5qQ6Y=gc+TH3SrKuJJgaQDFA@mail.gmail.com>
Subject: NFS + Kerberos/PKINIT: server identity.
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear hackers,

I am trying to set up an NFS + (Kerberos with PKINIT) server. I don't
know much about NFS and Kerberos. I am sorry if my questions are too
dumb!

I am thinking about the use of the Kerberos keytab file.

When setting up the Kerberos and Pkinit, server and client agree to
trust the same Certificate Authority, by setting the pkinit_anchors in
kdc.conf. Now, as long as the client trusts the CA, I believe the
client would not need a keytab entry for the nfs/hostname@realm, as
long as we are able to pass this information (nfs server principal) to
the mount command. For example:
$ mount -t nfs4 -o server_principal=3Dnfs/xyz@realm,sec=3Dkrb5p
server:/exports/directory /mount_point

Is this a bad idea? I understand that with keytab, the filesystem user
gets to decide if he trusts or not the nfs server credentials. The way
I am suggesting, the "mounter" gets to decide. However, I do not see a
reason the user shall not trust root. This could solve the problem of
determining the canonical hostname of a service server. As far as I
understood, in this context, the correct DNS configuration and correct
detection of the canonical hostname are important for this guess on
the principal name. Reference: section 3.4 at
https://www.ietf.org/rfc/rfc3530.txt

The same way, the nfs server does not seem to need a keytab if there
is any mechanism to translate Kerberos principals to user ids. This
because the certificates already contains the information on the
principal.

It would be nice to get rid of keytab and dns in this case...


Happy hacking,
Andr=C3=A9 Caldas.
