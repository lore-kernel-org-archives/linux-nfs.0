From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] prevent sunrpc deadlock with debug on
Date: Wed, 5 Jan 2005 17:44:55 +0100
Message-ID: <20050105164455.GI26856@suse.de>
References: <20041216165714.GB2077@suse.de> <1104277396.3976.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmEfw-0000fL-MG
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 09:10:24 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CmEfs-00017n-16
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 09:10:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1104277396.3976.10.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Trond,

On Wed, Dec 29, 2004 at 12:43:16AM +0100, Trond Myklebust wrote:
> I think I've found the real bug that Shirly was seeing. Can you ask her
> to test if this change fixes the actual problem?

I don't think that will be possible, but I'll ask her. The patch does
look correct though.

Still, if we ever run into a corrupted task struct, we will still
deadlock. How about this:

  show_tasks(void)
  {
        struct list_head *le;
        struct rpc_task *t;

-       spin_lock(&rpc_sched_lock);
+	if (!spin_trylock(&rpc_sched_lock))
+		return;
        if (list_empty(&all_tasks)) {
                spin_unlock(&rpc_sched_lock);


Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
