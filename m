From: Scott McDermott <mcdermot@questra.com>
Subject: Re: NFS Locking Issue - Solaris-Linux
Date: Wed, 23 Oct 2002 12:21:31 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023122131.G14314@questra.com>
References: <CFEAJJEGMGECBCJFLGDBMECLCGAA.enorwood@effrem.com> <3DB56CF3.29848F2F@neolinear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186] helo=questra.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184U1G-0001Rq-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 15:30:30 -0700
Received: (from mcdermot@localhost)
	by odio.roc.questra.com (8.11.6/8.11.4) id g9NGLVf18339
	for nfs@lists.sourceforge.net; Wed, 23 Oct 2002 12:21:31 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <3DB56CF3.29848F2F@neolinear.com>; from wschrier@neolinear.com on Tue, Oct 22, 2002 at 11:21:23AM -0400
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Bill Schrier on Tue 22/10 11:21 -0400:
> The corresponding line from our auto_direct table follows:
> /zone           -actimeo=0,vers=2       raidzone:/home

I thought vers=2 did not support the NLM (so you won't get locking).  I
seem to remember eagerly awaiting the v3 code and patching my machines
so I could get file locks.  That was a while ago...

why are you using vers=2 btw? I think you mentioned Solaris 2.6 as the
earliest version; that mounts v3 I think.


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
