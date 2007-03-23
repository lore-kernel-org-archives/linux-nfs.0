From: Neil Brown <neilb@suse.de>
Subject: Re: Question about f_count in struct nlm_file
Date: Fri, 23 Mar 2007 15:38:55 +1100
Message-ID: <17923.23007.774087.48762@notabene.brown>
References: <4603506D.5040807@redhat.com>
	<4603578C.6070200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: wcheng@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUbYR-0006RF-M4
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 21:39:07 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUbYS-0004Gz-PE
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 21:39:10 -0700
In-Reply-To: message from Wendy Cheng on Thursday March 22
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

On Thursday March 22, wcheng@redhat.com wrote:
> Wendy Cheng wrote:
> 
> >
> >client does posix lock -->
> >     server calls nlm4svc_proc_lock() ->
> >         * server lookup file (f_count++)
> >         * server lock the file
> >         * server calls nlm_release_host
> >         * server calls nlm_release_file (f_count--)
> >         * server return to client with status 0
> >
> >This will cause any call into nlm_traverse_files() to crash in the 
> >following path, if the file happens to be of "no interest" of the search 
> >(for example, the "match" function returns FALSE in all cases). Is this 
> >intentional or oversight ? Would 2.6.21-rc4 be a good base to do NLM 
> >development work ?

Hmmm.... definitely seems to be a bug in there!!

The key to the issue seems to be to make sure we take account of all
the current locks.
One way might be to replace
			if (list_empty(&file->f_blocks) && !file->f_locks
			 && !file->f_shares && !file->f_count) {
in nlm_traverse_files with a call to nlm_file_inuse(file).

Another way would be to try a bit harder to keep f_count uptodate by
incrementing it in nlmsvc_lock:

diff .prev/fs/lockd/svclock.c ./fs/lockd/svclock.c
--- .prev/fs/lockd/svclock.c	2007-03-23 15:30:37.000000000 +1100
+++ ./fs/lockd/svclock.c	2007-03-23 15:33:41.000000000 +1100
@@ -370,6 +370,7 @@ again:
 
 	switch(error) {
 		case 0:
+			file->f_locks ++;
 			ret = nlm_granted;
 			goto out;
 		case -EAGAIN:

The former is probably bit safer... but I wish I know what we have
that f_locks count.  It is not at all clear what it is needed for.
Maybe some legacy issue that doesn't exist any more...


> I should have made it clear... after nlm_inspect_file(), the logic 
> unconditionally checks for possible removing of this file. Since the 
> file is not blocked, nothing to do with shares, and f_count is zero, it 
> will get removed from hash and fclose() invoked (even it still owns a 
> plock). This will make VFS very unhappy and BUG() in fs/locks.c:1988 in 
> the middle of __fput -> locks_remove_flock.
> 
> On the other hand, the more I think (about this issue), maybe just 
> looping back after nlm_inspect_file finds no match would be good enough. 
> Anyway, that's what I'm going to do. Any objection ? Please let me know.

Could you explain this possible fix a bit more.  I'm not sure what you
are proposing..
Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
