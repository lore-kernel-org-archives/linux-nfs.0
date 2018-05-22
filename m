Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:38912 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbeEVUDu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:03:50 -0400
Received: by mail-ua0-f171.google.com with SMTP id v17-v6so13191501uak.6
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 13:03:50 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 22 May 2018 16:03:49 -0400
Message-ID: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
Subject: [RFC] protect against denial-of-service on a 4.0 mount
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm looking for comments on the approach to deal with the following
denial-of-service issue.

Currently, during the nfs4.0 mount, the code takes the content
supplied by the user in the mount command for "clientaddr" and that
becomes part of the content of the SETCLIENTID client id. There are no
verifications that the supplied address belongs to the client
initiating the mount.

A denial of services comes from where there are 2 clients with IP A
and IP B (bad one). Client IP A mounts and has "IP A" in the
SETCLIENTID. Client IP B does a mount and specified "clientaddr=IP A".
This causes the server to invalidate the lease for the legitimate
client IP A.

My suggested approach to fixing it, is to have nfs-utils do a sanity
checking that will check if the clientaddr that's suppose matches the
IP of the machine. Then currently, if it doesn't then it will ignore
the supplied value and use the IP of the machine. Whether this is
desirable vs say failing the mount and forcing the user to specify the
correct value is up for debate. Also, I'm not sure if the check for
the value of clientaddr should be done in the kernel itself instead of
the nfs-utils.

Below is the rough fix to the nfs-utils. Please comment.

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 1217823..982927e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -242,11 +242,21 @@ static int nfs_append_clientaddr_option(const
struct sockaddr *sap,
  struct sockaddr *my_addr = &address.sa;
  socklen_t my_len = sizeof(address);

- if (po_contains(options, "clientaddr") == PO_FOUND)
- return 1;
-
  nfs_callback_address(sap, salen, my_addr, &my_len);

+ if (po_contains(options, "clientaddr") == PO_FOUND) {
+ char *addr = po_get(options, "clientaddr");
+         char address[NI_MAXHOST];
+
+         if (!nfs_present_sockaddr(my_addr, my_len, address,
+ sizeof(address)))
+                 goto out;
+
+ if (strcmp(addr, address))
+ goto out;
+ return 1;
+ }
+out:
  return nfs_append_generic_address_option(my_addr, my_len,
  "clientaddr", options);
 }
