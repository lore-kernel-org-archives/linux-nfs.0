From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 20:03:58 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35353.207.214.87.84.1078167838.squirrel@webmail.uio.no>
References: <20040301081456.37082.qmail@web12823.mail.yahoo.com>
    <34574.207.214.87.84.1078162727.squirrel@webmail.uio.no>
    <40437AE4.4030407@lehman.com>
    <35336.207.214.87.84.1078166886.squirrel@webmail.uio.no>
    <404387DD.5010205@lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Shantanu Goel" <sgoel01@yahoo.com>,
     "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Axsqj-00061X-Bd
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 11:13:09 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AxsmR-00017h-6B
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 11:08:43 -0800
To: "Shantanu Goel" <Shantanu.Goel@lehman.com>
In-Reply-To: <404387DD.5010205@lehman.com>
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

På må , 01/03/2004 klokka 10:58, skreiv Shantanu Goel:
> >Simple round robin is not going to play well with NFSv2 style write
gathering on the server. Nor will it really work too efficiently with
standard readahead.
> >How about instead doing round-robin on blocks of, say, 16 requests per
cookie (which is the current maximum readahead value)? That should
allow
> >the server some efficiency on block operations without sacrificing your
fairness criterion.
> >
> We could make it static but how about we add a field "nr_batch" to 
rpc_clnt with a default of 16 but let the higher layer override it? This
way the NFS layer can set it to a different value for different 
servers.

If you want to make it tunable, then I suggest you just make it a global
variable, and set it up as a sysctl in /proc/sys/sunrpc. I doubt there is
much call for making this a per-mountpoint variable (we already have too
many tunables in the "mount" structure as it is).

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
