From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
 not stop?
Date: Tue, 16 Mar 2010 18:05:33 +0800
Message-ID: <4B9F57ED.4090100@cn.fujitsu.com>
References: <4B9772EB.9010909@cn.fujitsu.com> <20100310182401.GA23340@fieldses.org> <4B98413F.1080609@cn.fujitsu.com> <20100311155857.GC22587@fieldses.org> <4B9A0C7A.1000001@cn.fujitsu.com> <20100312230804.GN13941@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53219 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S937654Ab0CPKEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 06:04:11 -0400
In-Reply-To: <20100312230804.GN13941@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields :
> On Fri, Mar 12, 2010 at 05:42:18PM +0800, Mi Jinlong wrote:
>>
>> J. Bruce Fields:
>>> Our current NFS implementation just isn't designed to be able to shut
>>> down some components while leaving others running.
>>   Really? But the lockd started with nfs service start, but not nfslock service.
>>   And, lockd can't stop with statd at the same time. 
>>   Sometimes, the lockd will not synchronous with statd. Maybe this problem is a good example.
> 
> I'm sorry, I still don't understand.
> 
> Please take a look at section 3.1, 3.2, and 3.3 of the nfs-utils README
> file.  That describes the order in which servers should be started and
> stopped.

  Maybe that's my problem. 
  The status of lockd and statd, when testing.

         lockd                statd
           |                    |   <== service nfslock stop
       get KILL signal        stopd   ^
   and get into grace_period    |     |
           |                    |     | more than grace_period time
           |                    |     v
           |                    |   <== service nfslock start
      normal state              |
           |                  start   Client receive SM_NOTIFY and reclaime lock,
           |                    |     but out of grace_period time.
           v                    v

  As above, after nfslock service start, client cannot reclaime lock success.

thanks,
Mi Jinlong

