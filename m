Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:50901 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753198AbdGSN60 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 09:58:26 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 0361328005D
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:58:25 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id C308F1364
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:58:24 +0200 (MEST)
Date: Wed, 19 Jul 2017 15:58:24 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1535638152.4367330.1500472704645.JavaMail.zimbra@desy.de>
Subject: SETATTR without stateid
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear friends,

By running xfstest (generic/013) I have discovered client side misbehavior.
Consider the following test code:

-----

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


int main(int argc, char **argv)
{

  if (argc != 2) {
    fprintf(stderr, "Usage: %s <path>\n", argv[0]);
    exit(1);
  }

  int rc = truncate(argv[1], 8192);
  if (rc < 0) {
    perror("Failed to truncate the file");
    exit(4);
  }
  exit(0);
}


----

The expectation is that client will send a valid open stateid with SETATTR (rfc7530#16.32.4).
However, this is not the case - client just send's a SETATTR with size, but without any open.

BTW, older clients (RHEL6) will fail with EIO, latest kernel, 4.13.0-rc1 goes into an
infinite loop of SETATTR requests.

On the other hand, ftruncate works as expected, e.q. following example:

---
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


int main(int argc, char **argv)
{

  if (argc != 2) {
    fprintf(stderr, "Usage: %s <path>\n", argv[0]);
    exit(1);
  }

  int fd = open(argv[1], O_RDWR, 0644);
  if (fd < 0) {
    perror("Failed to open file");
    exit(2);
  }

  int rc = ftruncate(fd, 8192);
  if (rc < 0) {
    perror("Failed to truncate the file");
    exit(4);
  }

  close(fd);
  exit(0);
}
----
Will provide an open stateid with SETATTR requests as mandated by rfc.

Tigran.
