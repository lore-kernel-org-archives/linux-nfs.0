From: Olaf Kirch <okir@suse.de>
Subject: Re: Locking patches (generic & nfs)
Date: Tue, 23 Jul 2002 17:06:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020723170615.D1869@suse.de>
References: <20020719101950.A15819@suse.de> <shsy9c27asf.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.suse.de ([213.95.15.193] helo=Cantor.suse.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X1FN-00036c-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 08:06:45 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsy9c27asf.fsf@charged.uio.no>
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

On Tue, Jul 23, 2002 at 04:56:32PM +0200, Trond Myklebust wrote:
> I disagree. As it stands, NLM_NEVER == (~(unsigned long)0), and "when"
> is unsigned long, so the only thing we need to protect against is if
> we hit the 'magic value' NLM_NEVER. Note that the time_before_eq()
> comparison ensures that we cope well with jiffy wraparound etc, so the
> entry should *not* in fact get put at the end of the list as you
> claimed.
> 
> With the above change (plus your change to set NLM_NEVER=0x7fffffff),
> we end up never retrying locks that just happen to have been put on
> the list at a time when the value of 'jiffies' happens to be > 0x7fffffff.

But as it is today, all blocked locks get inserted at the end of the
list because time_before_eq does a signed comparison! With the unpatched
code, when you have a blocked lock, and the conflicting lock is removed,
lockd will never send out a GRANTED_MSG. Because the blocked lock is at the
end of the list, and never picked up.

That's the real reason for changing NLM_NEVER to the largest _signed_
quantity. And if you do that, you need to deal with jiffy wraparound.
Maybe the way I did it is not optiomal, I concede. But you can't leave
it at ~0UL.

> Patrice Dumas recently did some work on implementing this both for
> NLMv1,2,3 and NLM4, so I was planning on integrating his changes into
> 2.4.20.

As you can see from the patch, it's not really much you need to add.
The functionality is all there, one only needs to decode the GRANTED_RES
call rather than dropping it.

Olaf
-- 
Olaf Kirch     |  Anyone who has had to work with X.509 has probably
okir@suse.de   |  experienced what can best be described as
---------------+  ISO water torture. -- Peter Gutmann


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
