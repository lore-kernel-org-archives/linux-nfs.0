Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65406.mail.ac4.yahoo.com ([76.13.9.26]:38533 "HELO
	web65406.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753022Ab1DAChH convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2011 22:37:07 -0400
Message-ID: <155181.50193.qm@web65406.mail.ac4.yahoo.com>
Date: Thu, 31 Mar 2011 19:37:04 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: readdirplus/getattr
To: linux-nfs@vger.kernel.org
In-Reply-To: <510884.31321.qm@web65410.mail.ac4.yahoo.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Setting actimeo=600 gave me part of the behaviour I expected; on the first directory listing, the calls were all readdirplus and no getattr.

However, there were now long stretches where nothing was happening.  During a single directory listing to a loaded server, there'd be:

 ~10 seconds of readdirplus calls and replies, followed by
 ~70 seconds of nothing, followed by
 ~10 seconds of readdirplus calls and replies, followed by
 ~100 seconds of nothing, followed by
 ~10 seconds of readdirplus calls and replies, followed by
 ~110 seconds of nothing, followed by
 ~2 seconds of readdirplus calls and replies

Why the long stretches of nothing?  If I'm reading my tshark output properly, it doesn't seem like the client was waiting for a server response.  Here are a couple of lines before and after a long stretch of nothing:

 28.575537 192.168.10.158 -> 192.168.10.5 NFS V3 READDIRPLUS Call, FH:0xa216e302
 28.593943 192.168.10.5 -> 192.168.10.158 NFS V3 READDIRPLUS Reply (Call In 358) random_1168.exr random_2159.exr random_2188
.exr random_0969.exr random_1662.exr random_0022.exr random_0785.exr random_2316.exr random_0831.exr random_0443.exr random_
1203.exr random_1907.exr
 28.594006 192.168.10.158 -> 192.168.10.5 NFS V3 READDIRPLUS Call, FH:0xa216e302
 28.623736 192.168.10.5 -> 192.168.10.158 NFS V3 READDIRPLUS Reply (Call In 362) random_1575.exr random_0492.exr random_0335
.exr random_2460.exr random_0754.exr random_1114.exr random_2001.exr random_2298.exr random_1858.exr random_1889.exr random_
2249.exr random_0782.exr
103.811801 192.168.10.158 -> 192.168.10.5 NFS V3 READDIRPLUS Call, FH:0xa216e302
103.883930 192.168.10.5 -> 192.168.10.158 NFS V3 READDIRPLUS Reply (Call In 2311) random_0025.exr random_1665.exr random_231
1.exr random_1204.exr random_0444.exr random_0836.exr random_0332.exr random_0495.exr random_1572.exr random_1900.exr random
_2467.exr random_1113.exr
103.884014 192.168.10.158 -> 192.168.10.5 NFS V3 READDIRPLUS Call, FH:0xa216e302
103.965167 192.168.10.5 -> 192.168.10.158 NFS V3 READDIRPLUS Reply (Call In 2316) random_0753.exr random_2006.exr random_021
6.exr random_1824.exr random_1456.exr random_1790.exr random_1037.exr random_0677.exr random_2122.exr random_0101.exr random
_1741.exr random_2235.exr

Calls are sent and replies received at the 28 second mark, and then... nothing... until the 103 second mark.  I'm sure the server must be somehow telling the client that it's busy, but - at least with the tools I'm looking at - I don't see how.  Is tshark just hiding TCP delays and retransmits from me?

Thanks again.

Andrew


--- On Thu, 3/31/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:

> Interesting.  So the reason it's
> switching back and forth between readdirplus and getattr
> during the same ls command is because the command is taking
> so long to run that the cache is periodically expiring as
> the command is running?
> 
> I'll do some playing with actimeo to see if I'm actually
> understanding this.
> 
> Thanks!
> 
> Andrew
> 
> 
> --- On Thu, 3/31/11, Steven Procter <steven@risen.void.org>
> wrote:
> 
> > This is due to client caching. 
> > When the second ls -l runs the cache
> > contains an entry for the directory.  The client can
> > check if the cached
> > directory data is still valid by issuing a GETATTR on
> the
> > directory.
> > 
> > But this only validates the names, not the
> attributes,
> > which are not
> > actually part of the directory.  Those must be
> > refetched.  So the client
> > issues a GETATTR for each entry in the directory. 
> It
> > issues them
> > sequentially, probably as ls calls readdir() and then
> > stat()
> > sequentially on the directory entries.
> > 
> > This takes so long that the cache entry times out and
> the
> > next time you
> > run ls -l the client reloads the directory using
> > READDIRPLUS.
> > 
> > --Steven
> > 
> > > X-Mailer: YahooMailClassic/12.0.2
> > YahooMailWebService/0.8.109.295617
> > > Date:    Thu, 31 Mar 2011 15:24:15
> > -0700 (PDT)
> > > From:    Andrew Klaassen <clawsoon@yahoo.com>
> > > Subject: readdirplus/getattr
> > > To:    linux-nfs@vger.kernel.org
> > > Sender:    linux-nfs-owner@vger.kernel.org
> > > 
> > > Hi,
> > > 
> > > I've been trying to get my Linux NFS clients to
> be a
> > little snappier about listing large directories from
> > heavily-loaded servers.  I found the following
> > fascinating behaviour (this is with
> 2.6.31.14-0.6-desktop,
> > x86_64, from openSUSE 11.3, Solaris Express 11 NFS
> server):
> > > 
> > > With "ls -l --color=none" on a directory with
> 2500
> > files:
> > > 
> > >             
> > |      rdirplus   | 
> >   nordirplus   |
> > >             
> > |1st  |2nd  |1st  |1st  |2nd 
> > |1st  |
> > >             
> > |run  |run  |run  |run  |run 
> > |run  |
> > >             
> > |light|light|heavy|light|light|heavy|
> > >              |load
> > |load |load |load |load |load |
> > >
> --------------------------------------------------
> > > readdir      |   0
> > |   0 |   0 |  25
> > |   0 |  25 |
> > > readdirplus  | 209 |   0 | 276
> > |   0 |   0
> > |   0 |
> > > lookup       |  16
> > |   0 |  10 |2316 |   0
> > |2473 |
> > > getattr      |   1 |2501
> > |2452 |   1 |2465 |   1 |
> > > 
> > > The most interesting case is with rdirplus
> specified
> > as a mount option to a heavily loaded server.  The
> NFS
> > client keeps switching back and forth between
> readdirplus
> > and getattr:
> > > 
> > >  ~10 seconds doing ~70 readdirplus calls,
> > followed by
> > >  ~150 seconds doing ~800 gettattr calls,
> followed
> > by
> > >  ~12 seconds doing ~70 readdirplus calls,
> > followed by
> > >  ~200 seconds doing ~800 gettattr calls,
> followed
> > by
> > >  ~20 seconds doing ~130 readdirplus calls,
> > followed by
> > >  ~220 seconds doing ~800 gettattr calls
> > > 
> > > All the calls appear to get reasonably prompt
> replies
> > (never more than a second or so), which makes me
> wonder why
> > it keeps switching back and forth between the
> > strategies.  (Especially since I've specified
> rdirplus
> > as a mount option.)
> > > 
> > > Is it supposed to do that?
> > > 
> > > I'd really like to see how it does with
> readdirplus
> > ~only~, no getattr calls, since it's spending only 40
> > seconds in total on readdirplus calls compared to 570
> > seconds in total on (redundant, I think, based on the
> > lightly-loaded case) getattr calls.
> > > 
> > > It'd also be nice to be able to force
> readdirplus
> > calls instead of getattr calls for second and
> subsequent
> > listings of a directory.
> > > 
> > > I saw a recent thread talking about readdirplus
> > changes in 2.6.37, so I'll give that a try when I get
> a
> > chance to see how it behaves.
> > > 
> > > Andrew
> > > 
> > > 
> > > --
> > > To unsubscribe from this list: send the line
> > "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line
> "unsubscribe
> > linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
