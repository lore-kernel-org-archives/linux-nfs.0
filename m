Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:54891 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757239Ab2JWRgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 13:36:42 -0400
From: Nix <nix@esperi.org.uk>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, "Ted Ts'o" <tytso@mit.edu>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Schumaker\, Bryan" <Bryan.Schumaker@netapp.com>,
        Peng Tao <bergwolf@gmail.com>,
        "gregkh\@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: Heads-up: 3.6.2 / 3.6.3 NFS server oops: 3.6.2+ regression? (also an unrelated ext4 data loss bug)
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix>
	<20121023143019.GA3040@fieldses.org>
	<874nllxi7e.fsf_-_@spindle.srvr.nix>
	<20121023164621.GC3040@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90928CA6F@SACEXCMBX04-PRD.hq.netapp.com>
	<87vce1w241.fsf@spindle.srvr.nix>
Date: Tue, 23 Oct 2012 18:36:15 +0100
In-Reply-To: <87vce1w241.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Tue, 23 Oct 2012 18:05:18 +0100")
Message-ID: <87r4opw0og.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 Oct 2012, nix@esperi.org.uk uttered the following:

> On 23 Oct 2012, Trond Myklebust spake thusly:
>> On Tue, 2012-10-23 at 12:46 -0400, J. Bruce Fields wrote:
>>> Looks like there's some confusion about whether nsm_client_get() returns
>>> NULL or an error?
>>
>> nsm_client_get() looks extremely racy in the case where ln->nsm_users ==
>> 0.  Since we never recheck the value of ln->nsm_users after taking
>> nsm_create_mutex, what is stopping 2 different threads from both setting
>> ln->nsm_clnt and re-initialising ln->nsm_users?
>
> Yep. At the worst possible time:
>
> 	spin_lock(&ln->nsm_clnt_lock);
> 	if (ln->nsm_users) {
> 		if (--ln->nsm_users)
> 			ln->nsm_clnt = NULL;
> (1)		shutdown = !ln->nsm_users;
> 	}
> 	spin_unlock(&ln->nsm_clnt_lock);
>
> If a thread reinitializes nsm_users at point (1), after the assignment,
> we could well end up with ln->nsm_clnt NULL and shutdown false. A bit
> later, nsm_mon_unmon gets called with a NULL clnt, and boom.

Possible fix if so, utterly untested so far (will test when I can face
yet another reboot and fs-corruption-recovery-hell cycle, in a few
hours), may ruin performance, violate locking hierarchies, and consume
kittens:

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e4fb3ba..da91cdf 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -98,7 +98,6 @@ static struct rpc_clnt *nsm_client_get(struct net *net)
 		spin_unlock(&ln->nsm_clnt_lock);
 		goto out;
 	}
-	spin_unlock(&ln->nsm_clnt_lock);
 
 	mutex_lock(&nsm_create_mutex);
 	clnt = nsm_create(net);
@@ -108,6 +107,7 @@ static struct rpc_clnt *nsm_client_get(struct net *net)
 		ln->nsm_users = 1;
 	}
 	mutex_unlock(&nsm_create_mutex);
+	spin_unlock(&ln->nsm_clnt_lock);
 out:
 	return clnt;
 }

