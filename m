Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41700 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbaJQS6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 14:58:21 -0400
Received: by mail-ie0-f172.google.com with SMTP id rl12so1337825iec.31
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 11:58:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <544156FE.7070905@windriver.com>
References: <544156FE.7070905@windriver.com>
From: Austin Schuh <austin@peloton-tech.com>
Date: Fri, 17 Oct 2014 11:58:00 -0700
Message-ID: <CANGgnMYqgaCDPAr7Q8qx3BW5_w9HsNv-uHcVERphfMxcak7vvg@mail.gmail.com>
Subject: Re: Hang writing to nfs-mounted filesystem from client, all nfsd
 tasks on server blocked in D
To: Chris Friesen <chris.friesen@windriver.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>, tytso <tytso@mit.edu>,
        "adilger.kernel" <adilger.kernel@dilger.ca>,
        rt-users <linux-rt-users@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2014 at 10:50 AM, Chris Friesen
<chris.friesen@windriver.com> wrote:
> Where generic_file_aio_write() is calling mutex_lock(&inode->i_mutex).


Use the 121 patch.  This sounds very similar to the issue that I
helped debug with XFS.  There ended up being a deadlock due to a bug
in the kernel work queues.  You can search the RT archives for more
info.
