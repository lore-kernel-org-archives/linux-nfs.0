Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-cloud1.xs4all.nl ([194.109.24.61]:18414 "EHLO
	smtp-cloud1.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbZGIMo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2009 08:44:58 -0400
Subject: Invalidating NFS attribute cache
From: Hans Kramer <hans.kramer@xs4all.nl>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain
Date: Thu, 09 Jul 2009 14:34:54 +0200
Message-Id: <1247142894.7427.43.camel@cancun.hanskramer.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

For some silly reason I have an application that needs to poll for the
existence of a certain file on a NFS share. 
(This is done from Sybase ASE ;-)

Now I run into the issue of attribute caching. Turning of the attribute
cache with the mount option of -o noac easily solves all the issues.

However, it would be nice if we could still use attribute caching and
force to invalidate on-demand the attribute cache.

After a lot of trying, the following solution seems to work for me now:
(pathname is the test file)   

#define _GNU_SOURCE

    char *copy = strdup(pathname);
    char *path = dirname(copy);

    int fd = open(path, O_DIRECTORY);
    if (fd >= 0)
        close(fd);

    free(copy);

    return access(pathname, F_OK);

Just opening the parent directory with O_DIRECTORY seems to do the
trick.

My questions: Is this hack going to work under every circumstance or
could it fail in the future with some update. Is there a ioctl call that
could the the same thing? That is invalidate the parent directory cache.
Or do I miss something completely ?-)

Thanks in advance

Hans  

