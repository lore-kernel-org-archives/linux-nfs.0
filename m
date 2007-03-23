From: Wendy Cheng <wcheng@redhat.com>
Subject: Question about f_count in struct nlm_file
Date: Thu, 22 Mar 2007 22:58:37 -0500
Message-ID: <4603506D.5040807@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUZps-0004TT-AK
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 19:49:01 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUZpu-0000Td-EW
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 19:49:02 -0700
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

I'm trying to finish the NLM lock failover work. The new NLM code in 
2.6.21-rc4 kernel is kind of confusing. To make the story short, could 
someone please explain how the server side's f_count (in struct 
nlm_file) is intended to be used ? My test program simply does a posix 
lock from NFS client without unlocking it (testing lock failover). Look 
like the server keeps the file in nlm_files hash but the f_count for 
that particular file is zero. The trace shows the following:

client does posix lock -->
     server calls nlm4svc_proc_lock() ->
         * server lookup file (f_count++)
         * server lock the file
         * server calls nlm_release_host
         * server calls nlm_release_file (f_count--)
         * server return to client with status 0

This will cause any call into nlm_traverse_files() to crash in the 
following path, if the file happens to be of "no interest" of the search 
(for example, the "match" function returns FALSE in all cases). Is this 
intentional or oversight ? Would 2.6.21-rc4 be a good base to do NLM 
development work ?

    260 /*
    261  * Loop over all files in the file table.
    262  */
    263 static int
    264 nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
    265 {
                   .............
    271         for (i = 0; i < FILE_NRHASH; i++) {
    272                 hlist_for_each_entry_safe(file, pos, next, 
&nlm_files[i]        , f_list) {
                                   ....
    274                         file->f_count++;
    275                         mutex_unlock(&nlm_file_mutex);
    276
    277                         /* Traverse locks, blocks and shares of 
this fil        e
    278                          * and update file->f_locks count */
    279                         if (nlm_inspect_file(host, file, match))
    280                                 ret = 1;
    281
    282                         mutex_lock(&nlm_file_mutex);
    283                         file->f_count--;
    284                         /* No more references to this file. Let 
go of it        . */
    285                         if (list_empty(&file->f_blocks) && 
!file->f_lock        s
    286                          && !file->f_shares && !file->f_count) {
    287                                 hlist_del(&file->f_list);
    288                                 nlmsvc_ops->fclose(file->f_file);
    289                                 kfree(file);

I can make the nlm_inspect_file() loops back (instead of trying to clean 
up the hash) to avoid this crash. But somehow the f_count logic sounds 
wrong to me. Why would a file that is still locked has a f_count zero in 
the hash ?

-- Wendy








-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
