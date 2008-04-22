From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Tue, 22 Apr 2008 19:15:20 -0400
Message-ID: <20080422231520.GI21770@fieldses.org>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34054 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812AbYDVXPe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 19:15:34 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JoRhz-0005bF-Ji
	for linux-nfs@vger.kernel.org; Wed, 23 Apr 2008 09:15:31 +1000
In-Reply-To: <20080418181918.GB24552@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 02:19:18PM -0400, bfields wrote:
> Really it should be now, though there's another week or so when we can
> submit stuff if it's in good shape.
> 
> But I'm feeling bad about letting this go recently, so I'll look at the
> last couple issues and do some testing over the next few days...

OK, I changed the return value to -EIO in the case locks weren't
unlocked.  (Better suggestions welcomed.  I notice lockd actually BUG()s
in a similar situation elsewhere in the code, but that's probably not
right.)

I also simplified the nlm_traverse_files() change so now it's just:

@@ -241,6 +248,8 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match)
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
 		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
+			if (is_failover_file && !is_failover_file(data, file))
+				continue;
 			file->f_count++;
 			mutex_unlock(&nlm_file_mutex);

Since the "continue" happens before we do anything at all with that
file, I believe this is safe, and avoids the need for the extra
nlm_file_inuse() call.

And I split the patch into two (unlock_ip, unlock_fs) and edited the
commit messages a little.

The only testing I've done was just connecthon tests plus a simple
manual test with unlock_filesystem (acquiring a lock from a client,
echoing path to unlock_filesystem, verifying that it's gone from
/proc/locks).

Revised patches follow....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

