From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
 restart
Date: Thu, 17 Dec 2009 17:34:20 +0800
Message-ID: <4B29FB1C.5020908@cn.fujitsu.com>
References: <4B275EA3.9030603@cn.fujitsu.com>	<F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com>	<4B28B5FD.5000103@cn.fujitsu.com> <20091216084902.64f722ad@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62498 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1764193AbZLQJcW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 04:32:22 -0500
In-Reply-To: <20091216084902.64f722ad-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton :
> On Wed, 16 Dec 2009 18:27:09 +0800
> Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> 
>>   The statd and lockd's state at server when nfslock restart:
>>
>>         lockd                   statd         |
>>                                               |
>>       host(monitored = 1)      /sm/client     |  client get locks success at first
>>           (locks)                             |
>>                                               |
>>       host(monitored = 1)      /sm/client     |  nfslock stop (lockd release client's locks)
>>           (no locks)                          |
>>                                               |  
>>       host(monitored = 1)      /sm/           |  nfslock start (client reclaim locks)
>>           (locks)                             |                (but statd don't monitor it)
>>
>>   note: host(monitored=1)  means: client's host struct is created, and is marked be monitored.
>>         (locks), (no locks)means: host strcut holds locks, or not.
>>         /sm/client         means: there have a file under /var/lib/nfs/statd/sm directory
>>         /sm/               means: /var/lib/nfs/statd/sm is empty!
>>
>>
> 
> Perhaps we ought to clear the cached list of monitored hosts (i.e. set
> them all to monitored = 0) when lockd gets a SIGKILL.

  Yes, if lockd can reuse the host struct, clear the cached list of
  monitored hosts is a good way when lockd gets a SIGKILL.

thanks,
Mi Jinlong

