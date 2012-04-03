Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63773 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2DCQZx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2012 12:25:53 -0400
Received: by wibhq7 with SMTP id hq7so3904856wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Apr 2012 09:25:52 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Trond.Myklebust@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [REGRESSION] NFSv4: open(O_TRUNC) hangs
Date: Tue, 03 Apr 2012 18:26:17 +0200
Message-ID: <87d37osrx2.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now this test program hangs on latest git.

Thanks,
Miklos
---

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	int res;
	char *name = argv[1];
	int fd;

	unlink(name);
	fd = creat(name, 0644);
	write(fd, "123", 3);
	close(fd);
	close(open(name, O_RDONLY | O_TRUNC));

	return 0;
}
