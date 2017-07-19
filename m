Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:34881 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753057AbdGSOWq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 10:22:46 -0400
Received: by mail-qt0-f179.google.com with SMTP id b40so2898326qtb.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 07:22:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1535638152.4367330.1500472704645.JavaMail.zimbra@desy.de>
References: <1535638152.4367330.1500472704645.JavaMail.zimbra@desy.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 19 Jul 2017 10:22:44 -0400
Message-ID: <CAN-5tyHecetnWKWiCbHfLWZ1REE+nyVoBQk9+VQ3QQO2jquraw@mail.gmail.com>
Subject: Re: SETATTR without stateid
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 19, 2017 at 9:58 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
> Dear friends,
>
> By running xfstest (generic/013) I have discovered client side misbehavior.
> Consider the following test code:
>
> -----
>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
>
>
> int main(int argc, char **argv)
> {
>
>   if (argc != 2) {
>     fprintf(stderr, "Usage: %s <path>\n", argv[0]);
>     exit(1);
>   }
>
>   int rc = truncate(argv[1], 8192);
>   if (rc < 0) {
>     perror("Failed to truncate the file");
>     exit(4);
>   }
>   exit(0);
> }
>
>
> ----
>
> The expectation is that client will send a valid open stateid with SETATTR (rfc7530#16.32.4).
> However, this is not the case - client just send's a SETATTR with size, but without any open.

SETATTR is allowed to send an all-zero stateid:

RFC7530 9.1.4.3

Anonymous Stateid:  When "other" and seqid are both zero, the stateid
      is treated as a special anonymous stateid, which can be used in
      READ, WRITE, and SETATTR requests to indicate the absence of any
      open state associated with the request.

> BTW, older clients (RHEL6) will fail with EIO, latest kernel, 4.13.0-rc1 goes into an
> infinite loop of SETATTR requests.

What does the server replies with in such case? I believe the client
assumes that SETATTR with all zeros will always be allowed and it will
not be checking anything if it gets BAD_STATEID and will automatically
re-try on BAD_STATEID with zero stateid (therefore it would explain
the loop you are seeing).

Older clients (RHEL6) did not have an option of retrying the SETATTR
that got the BAD_STATEID (on a delegation stateid) and retrying with
zero stateid which is allowed by the spec.

> On the other hand, ftruncate works as expected, e.q. following example:
>
> ---
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
>
>
> int main(int argc, char **argv)
> {
>
>   if (argc != 2) {
>     fprintf(stderr, "Usage: %s <path>\n", argv[0]);
>     exit(1);
>   }
>
>   int fd = open(argv[1], O_RDWR, 0644);
>   if (fd < 0) {
>     perror("Failed to open file");
>     exit(2);
>   }
>
>   int rc = ftruncate(fd, 8192);
>   if (rc < 0) {
>     perror("Failed to truncate the file");
>     exit(4);
>   }
>
>   close(fd);
>   exit(0);
> }
> ----
> Will provide an open stateid with SETATTR requests as mandated by rfc.

Yes that version of the user land "setattr" is on the file descriptor
so there was an opens stateid to be used by the nfs setattr.
"truncate" is on the file name and nfs does not underneath open a file
to satisfy this command.

>
> Tigran.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
