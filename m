From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Locking patches (generic & nfs)
Date: 23 Jul 2002 16:56:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <607.957554939453$1027436433@news.gmane.org>
References: <20020719101950.A15819@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X15i-0002BQ-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 07:56:46 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20020719101950.A15819@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Hi Olaf,

>>>>> " " == Olaf Kirch <okir@suse.de> writes:


     > --- linux/fs/lockd/svclock.c.locks Mon Jun 17 13:32:21 2002
     > +++ linux/fs/lockd/svclock.c Mon Jun 17 13:37:36 2002
     > @@ -62,8 +62,8 @@
     >  		nlmsvc_remove_block(block);
     >  	bp = &nlm_blocked; if (when != NLM_NEVER) {
     > - if ((when += jiffies) == NLM_NEVER)
     > - when ++;
     > + if ((when += jiffies) > NLM_NEVER)
     > + when = NLM_NEVER;
     >  		while ((b = *bp) &&
     >  		time_before_eq(b->b_when,when))
     >  			bp = &b->b_next;
     >  	} else

I disagree. As it stands, NLM_NEVER == (~(unsigned long)0), and "when"
is unsigned long, so the only thing we need to protect against is if
we hit the 'magic value' NLM_NEVER. Note that the time_before_eq()
comparison ensures that we cope well with jiffy wraparound etc, so the
entry should *not* in fact get put at the end of the list as you
claimed.

With the above change (plus your change to set NLM_NEVER=0x7fffffff),
we end up never retrying locks that just happen to have been put on
the list at a time when the value of 'jiffies' happens to be > 0x7fffffff.


-

The other fix for fs/locks.c looks reasonable AFAICS (but perhaps
Matthew wants to take a look?)

-

Concerning the fix implementing GRANTED_RES: I fully agree we need
it. I've just never had the time, and it's the sort of thing that
the Connectathon tests don't keep nagging at you with ;-)...

Patrice Dumas recently did some work on implementing this both for
NLMv1,2,3 and NLM4, so I was planning on integrating his changes into
2.4.20.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
