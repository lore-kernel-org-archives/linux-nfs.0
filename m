From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Wed, 22 Sep 2004 12:10:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040922101024.GC1528@suse.de>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org> <20040917022015.GA15212@fieldses.org> <16721.8596.980204.899779@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CA48B-0007pF-4n
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 03:13:47 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CA48A-0005D4-5K
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 03:13:47 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16721.8596.980204.899779@cse.unsw.edu.au>
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

On Wed, Sep 22, 2004 at 04:54:12PM +1000, Neil Brown wrote:
> One approach is the patches you produced.  Another might be a
> per-svc_procedure flag to say whether auth was required or not.  There
> are doubtlessly others.

I think the code in svcauth*.c should not concern itself with
authorization and make security policy decisions. It should parse the
credentials and verifier and call service specific routines that
make this decision. Specifically, stuff like ip_map_lookup() should
occur inside the policy routine, not in svcauth_unix_accept().

I also see no problem with having specific callback routines per
authentication flavor:

	int	(*pg_auth_null)(struct svc_rqst *);
	int	(*pg_auth_unix)(struct svc_rqst *, struct svc_auth_unix_data *);
	int	(*pg_auth_gss)(struct svc_rqst *, struct svc_auth_gss_data *);

If a program leaves one of these pointers NULL means "reject any request
with this auth flavor"

Of course, it makes sense to provide default implementations for all
auth flavors so that you don't have to cut'n'paste them for every
rpc service.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
