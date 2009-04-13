Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr17.xs4all.nl ([194.109.24.37]:1406 "EHLO
	smtp-vbr17.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZDMT0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 15:26:07 -0400
Subject: Re: Unexplained NFS mount hangs
From: Rudy Zijlstra <rudy@grumpydevil.homelinux.org>
Reply-To: Rudy@grumpydevil.homelinux.org
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Daniel Stickney <dstickney@pronto.com>, linux-nfs@vger.kernel.org
In-Reply-To: <48017BBF-03BD-4C87-84F1-1D3603273E4F@oracle.com>
References: <20090413092406.304d04fb@dstickney2>
	 <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
	 <20090413104759.525161b2@dstickney2>
	 <48017BBF-03BD-4C87-84F1-1D3603273E4F@oracle.com>
Content-Type: text/plain
Date: Mon, 13 Apr 2009 21:25:07 +0200
Message-Id: <1239650707.13583.49.camel@poledra.romunt.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Op maandag 13-04-2009 om 13:08 uur [tijdzone -0400], schreef Chuck
Lever:
> On Apr 13, 2009, at 12:47 PM, Daniel Stickney wrote:
> 
> > On Mon, 13 Apr 2009 12:12:47 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> On Apr 13, 2009, at 11:24 AM, Daniel Stickney wrote:
> >>> Hi all,
> >>>
> >>> I am investigating some NFS mount hangs that we have started to see
> >>> over the past month on some of our servers. The behavior is that the
> >>> client mount hangs and needs to be manually unmounted (forcefully
> >>> with 'umount -f') and remounted to make it work. There are about 85
> >>> clients mounting a partition over NFS. About 50 of the clients are
> >>> running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of
> >>> these 50 has ever had this mount hang. The other 35 are CentOS 5.2
> >>> with kernel 2.6.27 which was compiled from source. The mount hangs
> >>> are inconsistent and so far I don't know how to trigger them on
> >>> demand. The timing of the hangs as noted by the timestamp in /var/
> >>> log/messages varies. Not all of the 35 CentOS clients have their
> >>> mounts hang at the same time, and the NFS server continues operating
> >>> apparently normally for all other clients. Normally maybe 5 clients
> >>> have a mount hang per week, on different days, mostly different
> >>> times. Now and then we might see a cluster of a few clien
> >>> ts have their mounts hang at the same exact time, but this is not
> >>> consistent. In /var/log/messages we see
> >>>
> >>> Apr 12 02:04:12 worker120 kernel: nfs: server broker101 not
> >>> responding, still trying
> >>
> >> Are these NFS/UDP or NFS/TCP mounts?
> >>
> >> If you use a different kernel (say, 2.6.26) on the CentOS systems, do
> >> the hangs go away?
> >
> > Hi Chuck,
> >
> > Thanks for your reply. The mounts are NFSv3 over TCP. We have not  
> > tried a different kernel (because of the number of servers to be  
> > upgraded), but that is next on to ToDo list. Wanted to explore the  
> > possibility that some other change might resolve the issue, but I am  
> > getting close to launching the kernel upgrades. (The prepackaged  
> > RHEL/CentOS 2.6.18* kernels have other NFS client problems with  
> > attribute caching which really mess things up, so that is why we  
> > have had to compile from source)
> >
> > To add a little more info, in a post on April 10th titled "NFSv3  
> > Client Timeout on 2.6.27" Bryan mentioned that his client socket was  
> > in state FIN_WAIT2, and server in CLOSE_WAIT, which is exactly what  
> > I am seeing here.
> >
> > tcp        0      0 worker120.cluster:944        
> > broker101.cluster:nfs       FIN_WAIT2
> >
> > This is especially interesting because the original nfs "server not  
> > responding" message was about 32 hours ago. On this same client, all  
> > other NFS mounts to other servers are showing state "established".
> 
> Poking around in git, I see this recent commit:
> 
> commit 2a9e1cfa23fb62da37739af81127dab5af095d99
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Oct 28 15:21:39 2008 -0400
> 
>      SUNRPC: Respond promptly to server TCP resets
> 
>      If the server sends us an RST error while we're in the  
> TCP_ESTABLISHED
>      state, then that will not result in a state change, and so the  
> RPC client
>      ends up hanging forever (see
>      http://bugzilla.kernel.org/show_bug.cgi?id=11154)
> 
>      We can intercept the reset by setting up an sk->sk_error_report  
> callback,
>      which will then allow us to initiate a proper shutdown and retry...
> 
>      We also make sure that if the send request receives an  
> ECONNRESET, then we
>      shutdown too...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Which may address part of the problem.  If I'm reading the output of  
> "git describe" correctly, this one should be in 2.6.28.
> 

Chuck,

thanks a lot for this. 

I'm 90% certain i've had a hang on 2.6.28.2 (currently running 2.6.28.7
since March 14th on the writing clients). 

Too much HW related problems in the past weeks to be fully certain (and
me too much travelling and thus not at home). 


> There are a whole series of commits in this area that went upstream  
> about a month ago.  It's not clear if these are also necessary to  
> address the problem.  But they would be in 2.6.30-rc1.
> 

OK, i'll switch to 2.6.30 on all clients once it is out. Prefer to wait
for release, as they are production type machines. 

If i get a hang, i'll check with "netstat --ip"

Cheers,

Rudy


