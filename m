Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52183 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab0IOJ2a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 05:28:30 -0400
Message-ID: <4C9091A7.7030502@cn.fujitsu.com>
Date: Wed, 15 Sep 2010 17:28:07 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: =?UTF-8?B?5a6r5YuQ?= <shadowinlife@gmail.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: pNFS: trouble test with fscache
References: <AANLkTima6ASRztdzgm413VaBKLPEFt2SSa4JUkKQ9TqV@mail.gmail.com>
In-Reply-To: <AANLkTima6ASRztdzgm413VaBKLPEFt2SSa4JUkKQ9TqV@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> S:
> 
> I want to get benchmark from pNFS+ fscache with iozone
> 
> But  iozone can't work well
> /proc/fs/nfsfs/volumes   show that  the fsc is YES
> 
> I have open cachefiled and mount a ssd (ext3/user_xattr) on /var/fscache
> 
> When I use iozone to test read/re-read   it can't write page to the SSD DISK
> 
> /var/log/messages  show that  first it can write 4 pages successfully
> 
> after NFS: nfs_getpages_from_fscache: no page: -105

  Please confirm whether do you have enough memory when get this error,
  i guess iozone eats lot of memory.

  And, maybe the information of /proc/fs/fscache/states is useful, please
  puts it.

-- 
Regards
Bian Naimeng

