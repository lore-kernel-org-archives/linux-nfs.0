From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 03 Mar 2004 18:27:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078356429.3259.310.camel@nidelv.trondhjem.org>
References: <20040303032213.58494.qmail@web12823.mail.yahoo.com>
	 <40461CCC.5040609@lehman.com>
	 <1078338902.3259.13.camel@nidelv.trondhjem.org>
	 <40462D4C.1060006@lehman.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <sgoel01@yahoo.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyfrK-0004oH-SR
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 15:33:02 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AyfSa-00069h-Dg
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 15:07:28 -0800
To: Shantanu Goel <Shantanu.Goel@lehman.com>
In-Reply-To: <40462D4C.1060006@lehman.com>
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

P=E5 on , 03/03/2004 klokka 14:09, skreiv Shantanu Goel:
> Will do.  Is the rpc throttle patch acceptable now for inclusion?

I have a couple of fixups to do in order to be able to append it to the
NFS4_ALL patch, but otherwise it looks OK.

I haven't tested it yet, though...

A couple of minor gripes (which I'm in the process of fixing up)

        - nfs_writepage_async() really doesn't need a "how" parameter.
        It only allocates an nfs_page().
       =20
        - Several of those #defines really ought to be inline functions.
       =20
        - Let's get rid of RPC_WAITQ_MARK_PRIORITY(), and instead make
        an rpc_init_priority_waitq(). Changing the value of
        queue->levels at any time after initialization looks really
        dangerous.
       =20
        - Your use of task->tk_flags inside
        __rpc_remove_wait_queue_priority() looks unsafe. Recall that
        soft irqs may call that function, and if they do so while
        someone else is touching that variable, then information may get
        clobbered.
        In addition, that whole flag seems redundant. Just checking for
        list_empty(&task->tk_links) should suffice AFAICS...
       =20
        - I really don't like rpc_cookie in the struct rpc_message. It
        has nothing to do with the actual RPC payload at all. Let's
        leave it in the rpc_task.
       =20
        - A couple of list_del()+list_add*() combinations looked like
        candidates for list_move*() conversion.
       =20
        - We really need to do something about "task_for_first()". I
        realize that isn't your fault (Neil introduced it IIRC) but it
        is very confusing, not to mention ugly, to be hiding an if
        statement inside a macro like that.
       =20
        - I'm a bit worried about the RPC_PRIORITY_HIGH tasks hogging
        all the queues. I suggest we just make the high priority queue
        equivalent to the 2 other queues, but that we set queue->count
        to 8.
        If that doesn't work, we can go back to making it always be
        served.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
