From: Chip Salzenberg <chip@pobox.com>
Subject: Re: [KNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Mon, 21 Mar 2005 11:39:40 -0500
Message-ID: <20050321163940.GF1736@perlsupport.com>
References: <423EDD43.8000209@RedHat.com> <20050321154645.GE1736@perlsupport.com> <423EF4CE.90501@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDPwY-0000nu-OI
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:39:54 -0800
Received: from perlsupport.com
	([66.180.163.120] helo=mail.perlsupport.com ident=6e343bdac25f70f4dba1daedeab59554)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDPwW-00036c-TQ
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:39:55 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <423EF4CE.90501@RedHat.com>
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

According to Steve Dickson:
> Chip Salzenberg wrote:
> >Thanks very much for the patches, but would you please add on support
> >for the '-V' flag specifying the versions that should be allowed?
> Well since everything is on by default, I figured all that
> was needed was a way to turn things off, but it would
> be a non-issue to add.

It's for future-proofing.  Suppose you only wanted to export NFSv3,
that's all.  You could say "-N 2" and that would be fine ... until
NFSv4 was invented, when you'd need "-N 2,4".  Spelling it as "-V 3"
is more stable for the long term.

> I was thinking servers behind firewalls might want to explicitly
> define one protocol or the other, just to keep things simple [...]

OK thanks.  A little doc patch might be helpful, if only along the
lines of "if you're not setting up firewall rules, these options
probably won't matter to you".
-- 
Chip Salzenberg            - a.k.a. -            <chip@pobox.com>
         Open Source is not an excuse to write fun code
            then leave the actual work to others.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
