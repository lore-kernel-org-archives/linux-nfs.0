From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 008 of 11] knfsd: add svc_set_num_threads
Date: Sun, 30 Jul 2006 21:11:30 -0700
Message-ID: <20060730211130.be44c1d0.akpm@osdl.org>
References: <20060731103458.29040.patches@notabene>
	<1060731004223.29267@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7P7t-0003o5-BS
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:11:33 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G7P7s-000648-FG
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:11:33 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060731004223.29267@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 31 Jul 2006 10:42:23 +1000
NeilBrown <neilb@suse.de> wrote:

> +	/* destroy old threads */
> +	while (nrservs < 0 &&
> +	       (victim = choose_victim(serv, pool, &state)) != NULL) {
> +		send_sig(serv->sv_kill_signal, victim, 1);
> +		nrservs++;

Using signals to communicate with kernel threads is rather baroque - we
have a range of less klunky ways of controlling kernel threads in-kernel.

The containers guys are going through converting lots of these things over
to the kthread API - I believe it's a requirement for containerisation.

nfsd/rpc is going to be one of the hard ones to convert, but it's going to
happen.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
