Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:24564 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab3KLRgR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:36:17 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 1/2] sunrpc: create a new dummy pipe for gssd to hold
 open
Date: Tue, 12 Nov 2013 17:36:15 +0000
Message-ID: <1384277770.4779.27.camel@leira.trondhjem.org>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
	 <1384261225-28559-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384261225-28559-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 08:00 -0500, Jeff Layton wrote:
+AD4- rpc.gssd will naturally hold open any pipe named +ACo-/clnt+ACo-/gssd that shows
+AD4- up under rpc+AF8-pipefs. That behavior gives us a reliable mechanism to tell
+AD4- whether it's actually running or not.
+AD4- 
+AD4- Create a new toplevel +ACI-dummy+ACI- directory in rpc+AF8-pipefs when it's mounted.
+AD4- Under that directory create another directory called +ACI-clntXX+ACI-, and then
+AD4- within that a pipe called +ACI-gssd+ACI-.
+AD4- 
+AD4- We'll never send an upcall along that pipe, and any downcall written to
+AD4- it will just return -EINVAL.
+AD4- 
+AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-
+AD4- ---
+AD4-  net/sunrpc/netns.h    +AHw-  1 +-
+AD4-  net/sunrpc/rpc+AF8-pipe.c +AHw- 84 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
+AD4-  2 files changed, 85 insertions(+-)
+AD4- 
+AD4- diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
+AD4- index 779742c..6b82968 100644
+AD4- --- a/net/sunrpc/netns.h
+AD4- +-+-+- b/net/sunrpc/netns.h
+AD4- +AEAAQA- -15,6 +-15,7 +AEAAQA- struct sunrpc+AF8-net +AHs-
+AD4-  
+AD4-  	struct super+AF8-block +ACo-pipefs+AF8-sb+ADs-
+AD4-  	struct mutex pipefs+AF8-sb+AF8-lock+ADs-
+AD4- +-	struct dentry +ACo-gssd+AF8-dummy+ADs-
+AD4-  
+AD4-  	struct list+AF8-head all+AF8-clients+ADs-
+AD4-  	spinlock+AF8-t rpc+AF8-client+AF8-lock+ADs-
+AD4- diff --git a/net/sunrpc/rpc+AF8-pipe.c b/net/sunrpc/rpc+AF8-pipe.c
+AD4- index f94567b..1c54de6 100644
+AD4- --- a/net/sunrpc/rpc+AF8-pipe.c
+AD4- +-+-+- b/net/sunrpc/rpc+AF8-pipe.c
+AD4- +AEAAQA- -1168,6 +-1168,7 +AEAAQA- enum +AHs-
+AD4-  	RPCAUTH+AF8-nfsd4+AF8-cb,
+AD4-  	RPCAUTH+AF8-cache,
+AD4-  	RPCAUTH+AF8-nfsd,
+AD4- +-	RPCAUTH+AF8-dummy,
+AD4-  	RPCAUTH+AF8-RootEOF
+AD4-  +AH0AOw-
+AD4-  
+AD4- +AEAAQA- -1204,6 +-1205,10 +AEAAQA- static const struct rpc+AF8-filelist files+AFsAXQ- +AD0- +AHs-
+AD4-  		.name +AD0- +ACI-nfsd+ACI-,
+AD4-  		.mode +AD0- S+AF8-IFDIR +AHw- S+AF8-IRUGO +AHw- S+AF8-IXUGO,
+AD4-  	+AH0-,
+AD4- +-	+AFs-RPCAUTH+AF8-dummy+AF0- +AD0- +AHs-
+AD4- +-		.name +AD0- +ACI-dummy+ACI-,

+ACI-gssd+ACI- would be nicer.

+AD4- +-		.mode +AD0- S+AF8-IFDIR +AHw- S+AF8-IRUGO +AHw- S+AF8-IXUGO,
+AD4- +-	+AH0-,
+AD4-  +AH0AOw-
+AD4-  
+AD4-  /+ACo-
+AD4- +AEAAQA- -1253,6 +-1258,80 +AEAAQA- void rpc+AF8-put+AF8-sb+AF8-net(const struct net +ACo-net)
+AD4-  +AH0-
+AD4-  EXPORT+AF8-SYMBOL+AF8-GPL(rpc+AF8-put+AF8-sb+AF8-net)+ADs-
+AD4-  
+AD4- +-static const struct rpc+AF8-filelist dummy+AF8-clnt+AF8-dir+AFsAXQ- +AD0- +AHs-
+AD4- +-	+AFs-0+AF0- +AD0- +AHs-
+AD4- +-		.name +AD0- +ACI-clntXX+ACI-,
+AD4- +-		.mode +AD0- S+AF8-IFDIR +AHw- S+AF8-IRUGO +AHw- S+AF8-IXUGO,
+AD4- +-	+AH0-,
+AD4- +-+AH0AOw-
+AD4- +-
+AD4- +-static ssize+AF8-t
+AD4- +-dummy+AF8-downcall(struct file +ACo-filp, const char +AF8AXw-user +ACo-src, size+AF8-t len)
+AD4- +-+AHs-
+AD4- +-	return -EINVAL+ADs-
+AD4- +-+AH0-
+AD4- +-
+AD4- +-static const struct rpc+AF8-pipe+AF8-ops dummy+AF8-pipe+AF8-ops +AD0- +AHs-
+AD4- +-	.upcall		+AD0- rpc+AF8-pipe+AF8-generic+AF8-upcall,
+AD4- +-	.downcall	+AD0- dummy+AF8-downcall,
+AD4- +-+AH0AOw-
+AD4- +-
+AD4- +-/+ACoAKg-
+AD4- +- +ACo- rpc+AF8-gssd+AF8-dummy+AF8-populate - create a dummy gssd pipe
+AD4- +- +ACo- +AEA-root: root of the rpc+AF8-pipefs filesystem
+AD4- +- +ACo-
+AD4- +- +ACo- Create a dummy set of directories and a pipe that gssd can hold open to
+AD4- +- +ACo- indicate that it is up and running.
+AD4- +- +ACo-/
+AD4- +-static struct dentry +ACo-
+AD4- +-rpc+AF8-gssd+AF8-dummy+AF8-populate(struct dentry +ACo-root)
+AD4- +-+AHs-
+AD4- +-	int ret +AD0- 0+ADs-
+AD4- +-	struct dentry +ACo-gssd+AF8-dentry+ADs-
+AD4- +-	struct dentry +ACo-clnt+AF8-dentry +AD0- NULL+ADs-
+AD4- +-	struct dentry +ACo-pipe+AF8-dentry +AD0- NULL+ADs-
+AD4- +-	struct rpc+AF8-pipe +ACo-pipe+AF8-data +AD0- NULL+ADs-
+AD4- +-	struct qstr q +AD0- QSTR+AF8-INIT(files+AFs-RPCAUTH+AF8-dummy+AF0-.name,
+AD4- +-				  strlen(files+AFs-RPCAUTH+AF8-dummy+AF0-.name))+ADs-
+AD4- +-
+AD4- +-	/+ACo- We should never get this far if +ACI-gssd+ACI- doesn't exist +ACo-/
+AD4- +-	gssd+AF8-dentry +AD0- d+AF8-hash+AF8-and+AF8-lookup(root, +ACY-q)+ADs-
+AD4- +-	if (+ACE-gssd+AF8-dentry)
+AD4- +-		return ERR+AF8-PTR(-ENOENT)+ADs-
+AD4- +-
+AD4- +-	ret +AD0- rpc+AF8-populate(gssd+AF8-dentry, dummy+AF8-clnt+AF8-dir, 0, 1, NULL)+ADs-
+AD4- +-	if (ret) +AHs-
+AD4- +-		pipe+AF8-dentry +AD0- ERR+AF8-PTR(ret)+ADs-
+AD4- +-		goto out+ADs-
+AD4- +-	+AH0-
+AD4- +-
+AD4- +-	pipe+AF8-data +AD0- rpc+AF8-mkpipe+AF8-data(+ACY-dummy+AF8-pipe+AF8-ops, 0)+ADs-
+AD4- +-	if (IS+AF8-ERR(pipe+AF8-data)) +AHs-
+AD4- +-		pipe+AF8-dentry +AD0- ERR+AF8-CAST(pipe+AF8-data)+ADs-
+AD4- +-		pipe+AF8-data +AD0- NULL+ADs-
+AD4- +-		goto out+ADs-
+AD4- +-	+AH0-
+AD4- +-
+AD4- +-	q.name +AD0- dummy+AF8-clnt+AF8-dir+AFs-0+AF0-.name+ADs-
+AD4- +-	q.len +AD0- strlen(dummy+AF8-clnt+AF8-dir+AFs-0+AF0-.name)+ADs-
+AD4- +-	clnt+AF8-dentry +AD0- d+AF8-hash+AF8-and+AF8-lookup(gssd+AF8-dentry, +ACY-q)+ADs-
+AD4- +-	if (+ACE-clnt+AF8-dentry) +AHs-
+AD4- +-		pipe+AF8-dentry +AD0- ERR+AF8-PTR(-ENOENT)+ADs-
+AD4- +-		goto out+ADs-
+AD4- +-	+AH0-
+AD4- +-
+AD4- +-	pipe+AF8-dentry +AD0- rpc+AF8-mkpipe+AF8-dentry(clnt+AF8-dentry, +ACI-gssd+ACI-, NULL, pipe+AF8-data)+ADs-
+AD4- +-	if (IS+AF8-ERR(pipe+AF8-dentry))
+AD4- +-		goto out+ADs-
+AD4- +-
+AD4- +-	pipe+AF8-data +AD0- NULL+ADs-
+AD4- +-out:
+AD4- +-	rpc+AF8-destroy+AF8-pipe+AF8-data(pipe+AF8-data)+ADs-
+AD4- +-	dput(clnt+AF8-dentry)+ADs-
+AD4- +-	dput(gssd+AF8-dentry)+ADs-
+AD4- +-	return pipe+AF8-dentry+ADs-
+AD4- +-+AH0-
+AD4- +-
+AD4-  static int
+AD4-  rpc+AF8-fill+AF8-super(struct super+AF8-block +ACo-sb, void +ACo-data, int silent)
+AD4-  +AHs-
+AD4- +AEAAQA- -1275,6 +-1354,11 +AEAAQA- rpc+AF8-fill+AF8-super(struct super+AF8-block +ACo-sb, void +ACo-data, int silent)
+AD4-  		return -ENOMEM+ADs-
+AD4-  	if (rpc+AF8-populate(root, files, RPCAUTH+AF8-lockd, RPCAUTH+AF8-RootEOF, NULL))
+AD4-  		return -ENOMEM+ADs-
+AD4- +-
+AD4- +-	sn-+AD4-gssd+AF8-dummy +AD0- rpc+AF8-gssd+AF8-dummy+AF8-populate(root)+ADs-
+AD4- +-	if (IS+AF8-ERR(sn-+AD4-gssd+AF8-dummy))
+AD4- +-		return PTR+AF8-ERR(sn-+AD4-gssd+AF8-dummy)+ADs-
+AD4- +-
+AD4-  	dprintk(+ACI-RPC:       sending pipefs MOUNT notification for net +ACU-p+ACU-s+AFw-n+ACI-,
+AD4-  		net, NET+AF8-NAME(net))+ADs-
+AD4-  	mutex+AF8-lock(+ACY-sn-+AD4-pipefs+AF8-sb+AF8-lock)+ADs-

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
