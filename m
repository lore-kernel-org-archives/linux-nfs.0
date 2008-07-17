From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Massive NFS problems on large cluster with large number of mounts
Date: Thu, 17 Jul 2008 10:47:25 -0400
Message-ID: <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org>
	 <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org>
	 <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de>
	 <20080716190658.GF20298@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Carsten Aulbert" <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	"Henning Fehrmann" <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	"Steffen Grunewald" <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:43211 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbYGQOr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2008 10:47:27 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1957875yxm.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2008 07:47:26 -0700 (PDT)
In-Reply-To: <20080716190658.GF20298@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2008 at 3:06 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jul 16, 2008 at 11:49:51AM +0200, Carsten Aulbert wrote:
>> Hi Trond et al.
>>
>> I'm following up on this discussion because we hit another problem:
>>
>> Trond Myklebust wrote:
>>
>> >
>> > Alternatively, just change the values of /proc/sys/sunrpc/min_resvport
>> > and /proc/sys/sunrpc/max_resvport to whatever range of ports you
>> > actually want to use.
>>
>> This works like a charm, however, if you set these values before
>> restarting the nfs-kernel-server then you are in deep trouble, since
>> when nfsd wants to start it needs to register with the portmapper, right?
>>
>> But what happens if this requests comes from a high^Wunpriviliged port?
>> Right:
>> Jul 16 11:46:43 d23 portmap[8216]: connect from 127.0.0.1 to set(nfs):
>> request from unprivileged port
>> Jul 16 11:46:43 d23 nfsd[8214]: nfssvc: writting fds to kernel failed:
>> errno 13 (Permission denied)
>> Jul 16 11:46:44 d23 kernel: [ 8437.726223] NFSD: Using
>> /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
>> Jul 16 11:46:44 d23 kernel: [ 8437.800607] NFSD: starting 90-second
>> grace period
>> Jul 16 11:46:44 d23 kernel: [ 8437.842891] nfsd: last server has exited
>> Jul 16 11:46:44 d23 kernel: [ 8437.879940] nfsd: unexporting all filesystems
>> Jul 16 11:46:44 d23 nfsd[8214]: nfssvc: Address already in use
>>
>>
>> Changing /proc/sys/sunrpc/max_resvport to 1023 again resolves this
>> issue, however defeats the purpose for the initial problem. I still need
>> to look into the code for hte portmapper, but is it easily possible that
>> the portmapper would accept nfsd requests from "insecure" ports also?
>> Since e are (mostly) in a controlled environment that should not pose a
>> problem.
>>
>> Anyone with an idea?
>
> The immediate problem seems like a kernel bug to me--it seems to me that
> the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
> is there some way the daemons can still know that those calls come from
> the local kernel?)

I tend to agree.  The rpcbind client (at least) does specifically
require a privileged port, so a large min/max port range would be out
of the question for those rpc_clients.

-- 
Chuck Lever
