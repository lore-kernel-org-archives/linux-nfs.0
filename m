Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34301 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbcGWUMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jul 2016 16:12:44 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so51474251pfb.1
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jul 2016 13:12:43 -0700 (PDT)
Received: from tornado.leadboat.com (c-98-248-47-228.hsd1.ca.comcast.net. [98.248.47.228])
        by smtp.gmail.com with ESMTPSA id nd4sm29022952pab.14.2016.07.23.13.12.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 13:12:41 -0700 (PDT)
Date: Sat, 23 Jul 2016 16:12:38 -0400
From: Noah Misch <noah@leadboat.com>
To: linux-nfs@vger.kernel.org
Subject: EACCES race when opening just-created file
Message-ID: <20160723201238.GA2134756@tornado.leadboat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

With the Linux kernel as both NFS client and server, I'm seeing a race
condition where open() can return EACCES for a just-created file.  Is this
expected behavior?  POSIX implicitly allows it, but I failed to locate any
discussion of it.  I have attached a test program; here, it witnesses the race
for roughly a dozen of the 4096 files it creates (different files each time).
One router separates client from server, with overall ping times as follows:

100 packets transmitted, 100 received, 0% packet loss, time 99039ms
rtt min/avg/max/mdev = 0.173/0.259/4.447/0.422 ms

This server has three similar clients, each of which witnesses the race.  I
did not reproduce this in a different NFS setup where client and server were
virtual machines on the same box.  Those are the only two environments I have
tested so far.

-- Server Details
[nm@gcc45 0:0 00:36:42 ~]$ uname -a
Linux gcc45 3.16.0-4-686-pae #1 SMP Debian 3.16.7-ckt11-1+deb8u3 (2015-08-04) i686 GNU/Linux
[nm@gcc45 0:0 00:36:37 ~]$ cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/home   gcc24.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)
/home   gcc23.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)
/home   gcc22.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)

-- Client Details
[nm@erpro8-fsf3 0:1 00:37:28 nfs]$ uname -a
Linux erpro8-fsf3 4.1.4 #1 SMP PREEMPT Mon Aug 3 14:22:54 PDT 2015 mips64 GNU/Linux
[nm@erpro8-fsf3 0:1 00:37:49 nfs]$ mount|grep nfs
gcc45.tetaneutral.net:/home on /home type nfs4 (rw,relatime,vers=4.0,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp6,port=0,timeo=600,retrans=2,sec=sys,clientaddr=2a03:7220:8083:9d00::1,local_lock=none,addr=2a03:7220:8081:8100::1)

Thanks,
nm

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfs-creat-eacces.c"

/*
 * Demonstrates open() returning EACCES for a recently-created file on NFS.  One
 * thread creates files nfs0 .. nfs4095 in the CWD, and another thread
 * continually attempts to open(O_RDWR) the latest file.  Prints a message
 * whenever the second thread sees open() fail in a way other than ENOENT.
 * Affected NFS configurations will print such messages for a selection of the
 * files, and immune configurations will print nothing.
 *
 * I abstracted this test case from a malfunction in the PostgreSQL database,
 * where one process opened a file just created in another process.  (See
 * src/interfaces/ecpg cases thread/thread and thread/prep.)
 */

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

/* no reader/writer synchronization; occasional disagreement is okay */
static int pos;

static void *
creator_task(void *arg)
{
    for (pos = 0; pos < (1 << 12); ++pos)
    {
	char buf[128];
	int fd;

	sprintf(buf, "nfs%d", pos);
	fd = open(buf, O_RDWR | O_CREAT | O_EXCL, 0600);
	if (fd < 0)
	    printf("could not create %s: %s\n", buf, strerror(errno));
	else if (close(fd) != 0)
	    printf("could not close %s after creation: %s\n",
		   buf, strerror(errno));
    }

    pos = -1;

    return NULL;
}

static void *
tester_task(void *arg)
{
    while (pos >= 0)
    {
	char buf[128];
	int fd;

	sprintf(buf, "nfs%d", pos);
	fd = open(buf, O_RDWR);
	if (fd < 0)
	{
	    if (errno != ENOENT)
		printf("could not open %s: %s\n", buf, strerror(errno));
	}
	else if (close(fd) != 0)
	    printf("could not close %s: %s\n", buf, strerror(errno));
    }

    return NULL;
}

int
main(int argc, char **argv)
{
    pthread_t creator;

    pthread_create(&creator, NULL, creator_task, 0);
    tester_task(NULL);
    pthread_join(creator, NULL);

    return 0;
}

--oyUTqETQ0mS9luUI--
