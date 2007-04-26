From: Neil Brown <neilb@suse.de>
Subject: Re: time_after cannot be used alone by NFS code in
	32bit	architectures
Date: Thu, 26 Apr 2007 16:13:30 +1000
Message-ID: <17968.17162.171856.702874@notabene.brown>
References: <20070426043344.GO10449@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgxEh-0001E0-Hb
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 23:13:47 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgxEi-00082P-Kv
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 23:13:50 -0700
In-Reply-To: message from Fabio Olive Leite on Thursday April 26
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

On Thursday April 26, fleite@redhat.com wrote:
> Hi nfs@,
> 
> This is going to be tough, so bear with me for a while. :)
> 
> While I was trying to understand the effects of wrapping jiffies in
> the various timestamp comparisons the NFS code does among its data
> structures, I was struck by cases where the code flow just did not
> make sense (checking with nfs_debug set to 32767 and additional
> systemtap scripts to extract debug info), considering the jiffy
> timestamps involved. This is the investigation that ensued.
> 
> time_after and friends provide a very clever way to compare two jiffy
> counts when those two counts are close together, and indeed does
> provide sign flip resistance, when the two values are close together.
> So it is ideal for short-lived timers and timeouts, since one would be
> usually comparing values a few thousands or even millions apart.
> 
> But unfortunately for the NFS code, time_after and friends alone are
> not well suited if we're just comparing jiffy counts taken at random
> times in the past instead of at moments close together. Exactly the
> protection against sign flips backfires when comparing timestamps over
> 2 billion counts apart.

Having found and fixed one issue with jiffie wrap recently (after 24
days, some web servers using NFS to access static content started
generating much higher levels of GETATTR requests), I understand the
possible problems, and agree that there could be issues.

However when I went looking to see if there could be other issues with
jiffie wrapping, my cursory look suggested not.  Most data structures
(inodes, dentries) that are completely unused for 24 days are
extremely likely to get flushed out of cache (there will be something
else that wants the memory) and anything that is used will get
timestamps refreshed regularly based on the attribute timeout in nfs
(which is usually less than one minute).

So I think this is only likely to be a problem for timestamps that do
not get refreshed in the general running on NFS.

One example is nfsi->cache_change_attribute.  If a file is unmodified
for 24 days, that can wrap, but there is now a fix for this in place.
Commit 3e7d950a528454ad749a264feef3c8bad3faa108 in Linus' git tree.

You seem to have found an identical issue with directories.
Presumably a similar fix can be used there.

Are you aware of any other jiffie-based timestamps that can actually
overflow before they are purged from memory or refreshed?

It is possible that 'cache_change_attribute' should be switch to a
64bit jiffie counter, but I don't think the problem is more general
than that.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
