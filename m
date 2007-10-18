From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Interesting problem with sunrpc cache
Date: Thu, 18 Oct 2007 09:47:15 -0400
Message-ID: <1192715235.7466.13.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiVia-0002I3-Bq
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 06:47:20 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiVid-0000sD-1f
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 06:47:25 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello,
    I have been working on a Domain of Interpretation mapper for the
labeled nfs work and I seem to have hit a wall. I started with idmapd as
a base and proceeded to modify it to work with DOIs instead. Because of
this with a few minor exceptions I expected everything to work. For the
most part it does however I seem to have a minor problem with the cache
on the nfsd side.

    I am running into a problem where I can't mount the export because
the server keeps trying to translate the label. I initially get a
success but then it repeatedly attempts to retry. I have tracked it down
to a bit of code which essentially is a duplication of
do_idmap_lookup_nowait. In this function we set ret to -ETIMEDOUT which
is -110 and then we test three conditions. The conditional checks if the
cache entry has the CACHE_VALID bit set, that the epiration time hasn't
lapsed and that the flush time hasn't lapsed. The last two conditions
here are true so I have determined it is because the CACHE_VALID bit
isn't being set properly. 

    This lead me to check deeper into where this bit is set. The answer
to this is that it should be set inside sunrpc_cache_update using the
cache_fresh_locked function. Entering this function we hit the two
conditions up top where it says that the valid bit isn't set and we
update it directly. The line below should update the valid bit since the
internals of cache_fresh_locked just set the expiry_time entry of cache
head and then use test_and_set_bit to set the CACHE_VALID bit in the
cache head's flags.

is_new = cache_fresh_locked(old, new->expiry_time);

    I am very perplexed why something like this is happening. I've been
trying to figure it out for the better part of a week and I have finally
hit the wall at this point. Has anyone else encountered this problem or
have any insight into why this might happen.

David Quigley



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
