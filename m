Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51156 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932355Ab2CFKKT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 05:10:19 -0500
Received: by eaaq12 with SMTP id q12so1752468eaa.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Mar 2012 02:10:17 -0800 (PST)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFSv4: truncate returns I/O error
CC: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Tue, 06 Mar 2012 11:10:11 +0100
Message-ID: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=

The attached test program reliably fails on an NFSv4 mount.

# mount -tnfs -onfsvers=4 127.0.0.1:/ /mnt/nfs
# ./truncate-test /mnt/nfs/tmp/xyz
truncate: Input/output error

Thanks,
Miklos


--=-=-=
Content-Type: text/x-csrc
Content-Disposition: inline; filename=truncate-test.c

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	int res;
	char *name = argv[1];

	unlink(name);
	close(open(name, O_WRONLY | O_CREAT, 0644));
	close(open(name, O_RDONLY));

	res = truncate(name, 1);
	if (res == -1) {
		perror("truncate");
		return 1;
	}
    return 0;
}

--=-=-=--
