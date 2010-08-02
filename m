Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63630 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab0HBJNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Aug 2010 05:13:52 -0400
Message-ID: <4C568C07.6080308@cn.fujitsu.com>
Date: Mon, 02 Aug 2010 17:12:39 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Dan Wallis <mrdanwallis@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: statd: server localhost not responding, timed out; lockd: cannot
 	monitor <client>
References: <AANLkTinZN+uhDShmg8aKiSEA8M3pr_RXu58OyyLPapxm@mail.gmail.com>
In-Reply-To: <AANLkTinZN+uhDShmg8aKiSEA8M3pr_RXu58OyyLPapxm@mail.gmail.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Hello list :)
> 
> This is my first post here, so if it's in the wrong place, or if I've
> not read the appropriate documentation, please feel free to send me a
> link to the relevant bits. I've tried searching the archives, and the
> internet at large, but haven't yet come across anything that's helped.

   ... snip ...

> I'm seeing these messages in the file server's system log:
> 
> Jul 30 09:37:17 fs0 kernel: [1810036.560046] statd: server localhost
> not responding, timed out
> Jul 30 09:37:17 fs0 kernel: [1810036.560053] nsm_mon_unmon: rpc
> failed, status=-5
> Jul 30 09:37:17 fs0 kernel: [1810036.560064] lockd: cannot monitor node2
> Jul 30 09:38:22 fs0 kernel: [1810101.384027] statd: server localhost
> not responding, timed out
> Jul 30 09:38:22 fs0 kernel: [1810101.384033] nsm_mon_unmon: rpc
> failed, status=-5
> Jul 30 09:38:22 fs0 kernel: [1810101.384044] lockd: cannot monitor node0
> 

  It looks like that nfslock service(statd) not running, please try run the
  followed command,

  # service rpcbind start
  # service nfslock restart

-- 
Regards
Bian Naimeng

