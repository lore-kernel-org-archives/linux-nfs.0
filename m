From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [NFS] NFS rpc and stale handles on 2.6.x servers
Date: Fri, 30 Jan 2004 11:46:31 +1100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16409.43367.545322.356713@notabene.cse.unsw.edu.au>
References: <4014675D.2040405@hanaden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <hanasaki@hanaden.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By note With Smtp ;
	Fri, 30 Jan 2004 11:46:32 +1100
To: hanasaki <hanasaki@hanaden.com>
In-Reply-To: message from hanasaki on Sunday January 25
List-ID: <nfs.lists.sourceforge.net>

On Sunday January 25, hanasaki@hanaden.com wrote:
> The below is being reported, on and off, when hitting nfs-kernel-servers
> running on 2.6.0 and 2.6.1  Could someone tell me if this is smoe bug or
> what?  Thanks
> 	RPC request reserved 0 but used 124
> 
> Debian sarge
> nfs-kernel-server
> am-untils
> nfsv3 over tcp
> 

stale file handles is a known bug that is fixed in the but BK and will
be in 2.6.3.

The "RPC request reserved 0 ..." is very odd. It does immediately
indicate a major problem, but it should be fixed, if only I could
figure out what was causing it.

I might put come more info into the message so future bug reports will
tell me more.

Thanks,
NeilBrown
