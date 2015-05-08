Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35674 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbbEHWui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2015 18:50:38 -0400
Received: by obcus9 with SMTP id us9so36241107obc.2
        for <linux-nfs@vger.kernel.org>; Fri, 08 May 2015 15:50:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431124677-13388-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <20150507140814.GF27106@fieldses.org>
	<1431124677-13388-1-git-send-email-andreas.gruenbacher@gmail.com>
Date: Sat, 9 May 2015 00:50:38 +0200
Message-ID: <CAHpGcM+i1ZDJUV4oRVV3q9f2GSiDTYBfmRyzsQzRCeM1ck6EzA@mail.gmail.com>
Subject: Re: [PATCH v2] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a little test for this:

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <utime.h>
#include <grp.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static int touch(const char *path, mode_t mode, bool current_time)
{
        if (current_time)
                return utime(path, NULL);
        else {
                time_t now = time(NULL);
                struct utimbuf times = {
                        .actime = now,
                        .modtime = now,
                };
                return utime(path, &times);
        }
}

static int su(uid_t uid, gid_t gid)
{
        int ret;

        ret = seteuid(0);
        if (ret != 0)
                return ret;
        ret = setegid(gid);
        if (ret != 0)
                return ret;
        ret = setgroups(0, NULL);
        if (ret != 0)
                return ret;
        ret = seteuid(uid);
        return ret;
}

static void die(const char *str)
{
        perror(str);
        exit(1);
}

void cleanup(void)
{
        su(0, 0);
        unlink("foo");
}

int main(void)
{
        int ret;

        atexit(cleanup);

        ret = creat("foo", 0600);
        if (ret < 0)
                die("foo");
        close(ret);
        ret = chown("foo", 0, 12345);
        if (ret != 0)
                die("foo");

        ret = su(12345, 12345);
        if (ret != 0)
                die("su");
        errno = 0;
        ret = touch("foo", 0660, true);
        if (ret == 0)
                die("touch should have failed");

        ret = su(0, 0);
        if (ret != 0)
                die("su");
        ret = chmod("foo", 0660);
        if (ret != 0)
                die("foo");

        ret = su(12345, 12345);
        if (ret != 0)
                die("su");
        errno = 0;
        ret = touch("foo", 0660, true);
        if (ret != 0)
                die("touch should have succeeded");

        ret = touch("foo", 0660, false);
        if (ret == 0)
                die("touch should fail on NFSv3+");

        return 0;
}
