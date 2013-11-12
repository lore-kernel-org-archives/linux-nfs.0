Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:62612 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327Ab3KLR4C convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:56:02 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 1/2] sunrpc: create a new dummy pipe for gssd to hold
 open
Date: Tue, 12 Nov 2013 17:56:00 +0000
Message-ID: <1384278957.4779.33.camel@leira.trondhjem.org>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
	 <1384261225-28559-2-git-send-email-jlayton@redhat.com>
	 <1384277770.4779.27.camel@leira.trondhjem.org>
	 <20131112124434.4e1c36b0@tlielax.poochiereds.net>
In-Reply-To: <20131112124434.4e1c36b0@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 12:44 -0500, Jeff Layton wrote:
+AD4- On Tue, 12 Nov 2013 17:36:15 +-0000
+AD4- +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Tue, 2013-11-12 at 08:00 -0500, Jeff Layton wrote:
+AD4- +AD4- +AD4- rpc.gssd will naturally hold open any pipe named +ACo-/clnt+ACo-/gssd that shows
+AD4- +AD4- +AD4- up under rpc+AF8-pipefs. That behavior gives us a reliable mechanism to tell
+AD4- +AD4- +AD4- whether it's actually running or not.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Create a new toplevel +ACI-dummy+ACI- directory in rpc+AF8-pipefs when it's mounted.
+AD4- +AD4- +AD4- Under that directory create another directory called +ACI-clntXX+ACI-, and then
+AD4- +AD4- +AD4- within that a pipe called +ACI-gssd+ACI-.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- We'll never send an upcall along that pipe, and any downcall written to
+AD4- +AD4- +AD4- it will just return -EINVAL.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-
+AD4- +AD4- +AD4- ---
+AD4- +AD4- +AD4-  net/sunrpc/netns.h    +AHw-  1 +-
+AD4- +AD4- +AD4-  net/sunrpc/rpc+AF8-pipe.c +AHw- 84 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
+AD4- +AD4- +AD4-  2 files changed, 85 insertions(+-)
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
+AD4- +AD4- +AD4- index 779742c..6b82968 100644
+AD4- +AD4- +AD4- --- a/net/sunrpc/netns.h
+AD4- +AD4- +AD4- +-+-+- b/net/sunrpc/netns.h
+AD4- +AD4- +AD4- +AEAAQA- -15,6 +-15,7 +AEAAQA- struct sunrpc+AF8-net +AHs-
+AD4- +AD4- +AD4-  
+AD4- +AD4- +AD4-  	struct super+AF8-block +ACo-pipefs+AF8-sb+ADs-
+AD4- +AD4- +AD4-  	struct mutex pipefs+AF8-sb+AF8-lock+ADs-
+AD4- +AD4- +AD4- +-	struct dentry +ACo-gssd+AF8-dummy+ADs-
+AD4- +AD4- +AD4-  
+AD4- +AD4- +AD4-  	struct list+AF8-head all+AF8-clients+ADs-
+AD4- +AD4- +AD4-  	spinlock+AF8-t rpc+AF8-client+AF8-lock+ADs-
+AD4- +AD4- +AD4- diff --git a/net/sunrpc/rpc+AF8-pipe.c b/net/sunrpc/rpc+AF8-pipe.c
+AD4- +AD4- +AD4- index f94567b..1c54de6 100644
+AD4- +AD4- +AD4- --- a/net/sunrpc/rpc+AF8-pipe.c
+AD4- +AD4- +AD4- +-+-+- b/net/sunrpc/rpc+AF8-pipe.c
+AD4- +AD4- +AD4- +AEAAQA- -1168,6 +-1168,7 +AEAAQA- enum +AHs-
+AD4- +AD4- +AD4-  	RPCAUTH+AF8-nfsd4+AF8-cb,
+AD4- +AD4- +AD4-  	RPCAUTH+AF8-cache,
+AD4- +AD4- +AD4-  	RPCAUTH+AF8-nfsd,
+AD4- +AD4- +AD4- +-	RPCAUTH+AF8-dummy,
+AD4- +AD4- +AD4-  	RPCAUTH+AF8-RootEOF
+AD4- +AD4- +AD4-  +AH0AOw-
+AD4- +AD4- +AD4-  
+AD4- +AD4- +AD4- +AEAAQA- -1204,6 +-1205,10 +AEAAQA- static const struct rpc+AF8-filelist files+AFsAXQ- +AD0- +AHs-
+AD4- +AD4- +AD4-  		.name +AD0- +ACI-nfsd+ACI-,
+AD4- +AD4- +AD4-  		.mode +AD0- S+AF8-IFDIR +AHw- S+AF8-IRUGO +AHw- S+AF8-IXUGO,
+AD4- +AD4- +AD4-  	+AH0-,
+AD4- +AD4- +AD4- +-	+AFs-RPCAUTH+AF8-dummy+AF0- +AD0- +AHs-
+AD4- +AD4- +AD4- +-		.name +AD0- +ACI-dummy+ACI-,
+AD4- +AD4- 
+AD4- +AD4- +ACI-gssd+ACI- would be nicer.
+AD4- +AD4- 
+AD4- 
+AD4- Ha+ACE- That's what my original patch had, but I thought that made it look
+AD4- too legit. I can respin and change it though if you like...

I'd prefer that. At least 'gssd' makes it clear that this is a directory
that we want gssd to be snooping.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
