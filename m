From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: Question about f_count in struct nlm_file
Date: Thu, 22 Mar 2007 23:29:00 -0500
Message-ID: <4603578C.6070200@redhat.com>
References: <4603506D.5040807@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUaJ9-0007NT-Fl
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 20:19:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUaJ8-0001Yp-MD
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 20:19:18 -0700
In-Reply-To: <4603506D.5040807@redhat.com>
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

Wendy Cheng wrote:

>
>client does posix lock -->
>     server calls nlm4svc_proc_lock() ->
>         * server lookup file (f_count++)
>         * server lock the file
>         * server calls nlm_release_host
>         * server calls nlm_release_file (f_count--)
>         * server return to client with status 0
>
>This will cause any call into nlm_traverse_files() to crash in the 
>following path, if the file happens to be of "no interest" of the search 
>(for example, the "match" function returns FALSE in all cases). Is this 
>intentional or oversight ? Would 2.6.21-rc4 be a good base to do NLM 
>development work ?
>
>    260 /*
>    261  * Loop over all files in the file table.
>    262  */
>    263 static int
>    264 nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
>    265 {
>                   .............
>    271         for (i = 0; i < FILE_NRHASH; i++) {
>    272                 hlist_for_each_entry_safe(file, pos, next, 
>&nlm_files[i]        , f_list) {
>                                   ....
>    274                         file->f_count++;
>    275                         mutex_unlock(&nlm_file_mutex);
>    276
>    277                         /* Traverse locks, blocks and shares of 
>this fil        e
>    278                          * and update file->f_locks count */
>    279                         if (nlm_inspect_file(host, file, match))
>    280                                 ret = 1;
>    281
>    282                         mutex_lock(&nlm_file_mutex);
>    283                         file->f_count--;
>    284                         /* No more references to this file. Let 
>go of it        . */
>    285                         if (list_empty(&file->f_blocks) && 
>!file->f_lock        s
>    286                          && !file->f_shares && !file->f_count) {
>    287                                 hlist_del(&file->f_list);
>    288                                 nlmsvc_ops->fclose(file->f_file);
>    289                                 kfree(file);
>
>I can make the nlm_inspect_file() loops back (instead of trying to clean 
>up the hash) to avoid this crash. But somehow the f_count logic sounds 
>wrong to me. Why would a file that is still locked has a f_count zero in 
>the hash ?
>
>  
>
I should have made it clear... after nlm_inspect_file(), the logic 
unconditionally checks for possible removing of this file. Since the 
file is not blocked, nothing to do with shares, and f_count is zero, it 
will get removed from hash and fclose() invoked (even it still owns a 
plock). This will make VFS very unhappy and BUG() in fs/locks.c:1988 in 
the middle of __fput -> locks_remove_flock.

On the other hand, the more I think (about this issue), maybe just 
looping back after nlm_inspect_file finds no match would be good enough. 
Anyway, that's what I'm going to do. Any objection ? Please let me know.

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
