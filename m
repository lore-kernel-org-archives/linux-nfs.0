From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale File handles keep coming back
Date: Wed, 04 May 2005 19:06:08 -0400
Message-ID: <1115247968.18875.6.camel@lade.trondhjem.org>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1115155275.2894.20.camel@localhost.localdomain>
	 <42786148.1000201@bio.ifi.lmu.de>
	 <1115246881.2523.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTSwl-0002x3-0i
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 16:06:27 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTSwj-0000ui-EZ
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 16:06:26 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: <1115246881.2523.14.camel@localhost.localdomain>
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

on den 04.05.2005 Klokka 15:48 (-0700) skreiv Kris Vassallo:

> Take a look at the following. It would be interesting to see if the
> 2.6.11 release on Suse fixes this problem (although I don't know if
> this has been released yet). 
> http://kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.11
> And I quote "<trond.myklebust@fys.uio.no> 
> 	NFSv2/v3/v4: ESTALE should not be a permanent condition on directories.
> 	

That client-side patch can do nothing to prevent errors from being
returned if a server is erroneously generating ESTALE.

It will just make it unnecessary to do the equivalent of "cd
`pwd`" (i.e. rewalk the path) on the client once the server manages to
sort itself out.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
