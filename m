From: Wendy Cheng <wcheng@redhat.com>
Subject: The host->h_inuse NLM's nlm_gc_hosts()
Date: Mon, 05 Jun 2006 03:54:18 -0400
Message-ID: <1149494058.5424.164.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fn9kp-0004Tb-NV
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 00:44:03 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fn9ko-0005sg-Ba
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 00:44:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fn9kn-0000Me-SI
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 00:44:02 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k557ht0x002754
	for <nfs@lists.sourceforge.net>; Mon, 5 Jun 2006 03:43:55 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [172.16.52.156])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k557htkv019290
	for <nfs@lists.sourceforge.net>; Mon, 5 Jun 2006 03:43:55 -0400
Received: from vpn50-28.rdu.redhat.com (vpn50-28.rdu.redhat.com [172.16.50.28])
	by pobox.corp.redhat.com (8.12.8/8.12.8) with ESMTP id k557ht78004674
	for <nfs@lists.sourceforge.net>; Mon, 5 Jun 2006 03:43:55 -0400
To: nfs@lists.sourceforge.net
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

I'm chasing a bug in our distribution - when signalling lockd, the lock
references do not seem to get released. I just spot the "nlm_gc_hosts"
explicitly set
 
   host->h_inuse = 0

then call nlmsvc_mark_resources() to remark h_inuse to 1 if there is a
lock reference via:

   nlmsvc_mark_resources ->
   nlm_traverse_files ->
   nlm_inspect_file->
   nlm_traverse_locks->

    183 again:
    184         file->f_locks = 0;
    185         for (fl = inode->i_flock; fl; fl = fl->fl_next) {
    186                 if (fl->fl_lmops != &nlmsvc_lock_operations)
    187                         continue;
    188
    189                 /* update current lock count */
    190                 file->f_locks++;
    191                 lockhost = (struct nlm_host *) fl->fl_owner;
    192                 if (action == NLM_ACT_MARK)
    193                         lockhost->h_inuse = 1;
    194                 else if (action == NLM_ACT_CHECK)
    195                         return 1;
    196                 else if (action == NLM_ACT_UNLOCK) {
    197                         struct file_lock lock = *fl;
    198
    199                         if (host && lockhost != host)
    200                                 continue;

So in theory, from #193, the lockhost->h_inuse is supposed to get set
back to 1. However, I'm wondering whether the fl->fl_owner would get
overwritten anywhere by (task_struct *)current->files in various other
code paths so we could end up updating different structures ? This could
allow the host gets freed such that nlmsvc_invalidate_all() will no
longer find this host ?

Will keep doing this bug hunt tomorrow but wondering someone knows this
code well can assure me that this won't happen ? Many thanks in advance.

Also the assumption here is that by sending lockd a (any) signal would
kickoff nlmsvc_invalidate_all() to remove the locks. Is this a correct
assumption ?

-- Wendy




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
