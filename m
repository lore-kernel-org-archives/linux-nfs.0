From: "NeilBrown" <neilb@suse.de>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Wed, 20 May 2009 11:05:34 +1000 (EST)
Message-ID: <bdacaae74fbd57ee96599286eae43751.squirrel@neil.brown.name>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com>
    <18963.13619.563465.804193@notabene.brown>
    <200905191925.38902.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
	"Linux NFS mailing list" <linux-nfs@vger.kernel.org>
To: "Mike Frysinger" <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33017 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888AbZETBFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 21:05:44 -0400
In-Reply-To: <200905191925.38902.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 20, 2009 9:25 am, Mike Frysinger wrote:
> On Tuesday 19 May 2009 18:39:47 Neil Brown wrote:
>> sm-notify :
>>    - is a 'client' for the "SM" protocol.
>>    - must be run at boot time, and after that is not needed.
>>
>> statd :
>>    - is a 'server' for the "SM" protocol.
>>    - only needs to be running when either nfsd is running or an
>>      nfs mount which supports locks is active
>
> that last part -- any nfs mount with locks -- means that pretty much every
> nfs
> client out there needs it running.
>
> sm-notify is pretty minuscule, so the overhead of having that run on a
> server
> is negligible, especially when combined with the already required statd.
> -mike
>

The point is that sm-notify should really be run at boot whenever
it is installed.
statd, being a server that listens to request from the network, should
only be run if it is needed (because most people like the policy of
only running network services that are actually needed).

If all nfs mounts are performed manually, then you might not want to
run statd for quite a long time after boot.  But you need to run
sm-notify immediately after boot to ensure that any locks you held
before the reboot get released.

They really are separate functions.

NeilBrown

