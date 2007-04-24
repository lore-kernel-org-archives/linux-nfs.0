From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Mon, 23 Apr 2007 23:30:56 -0400
Message-ID: <462D79F0.4060800@redhat.com>
References: <46156F3F.3070606@redhat.com>	<4625204D.1030509@redhat.com>
	<17959.5245.635902.823441@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgBa0-0000j4-3W
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 20:20:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgBa2-0002Mq-Bt
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 20:20:38 -0700
In-Reply-To: <17959.5245.635902.823441@notabene.brown>
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

Neil Brown wrote:

>One thing that has been bothering me is that sometimes the
>"filesystem" (in the guise of an fsid) is used to talk to the kernel
>about failover issues (when flushing locks or restarting the grace
>period) and sometimes the local network address is used (when talking
>with statd). 
>  
>

This is a perception issue - it depends on how the design is described. 
More on this later.

>I would rather use a single identifier.  In my previous email I was
>leaning towards using the filesystem as the single identifier.  Today
>I'm leaning the other way - to using the local network address.
>  
>
Guess you're juggling with too many things so forget why we came down to 
this route ? We started the discussion using network interface (to drop 
the locks) but found it wouldn't work well on local filesytems such as 
ext3. There is really no control on which local (sever side) interface 
NFS clients will use (shouldn't be hard to implement one though). When 
the fail-over server starts to remove the locks, it needs a way to find 
*all* of the locks associated with the will-be-moved partition. This is 
to allow umount to succeed. The server ip address alone can't guarantee 
that. That was the reason we switched to fsid. Also remember this is NFS 
v2/v3 - clients have no knowledge of server migration.

Now, let's move back to first paragraph. An active-active failover can 
be described as a 5-steps process:

Step 1. Quiesce the floating network address.
Step 2. Move the exported filesystem directories from Server A to Server B.
Step 3. Re-enable the network interface.
Step 4. Inform clients about the changes via NSM (Network Status 
Monitor) Protocol.
Step 5. Grace period.

I was told last week that, independent of lockd, some cluster 
filesystems do have their own implementation of grace period. It is on 
the wish list that this feature is taken into consideration. IMHO, the 
overall process should be viewed as a collaboration between filesystem, 
network interface, and NFS protocol itself. Mixing the filesystem and 
network operations are unavoidable.

On the other hand, the current proposed interface is expandable .. say, 
prefix a non-numerical string "DEV" or "UUID" to ask for dropping locks 
as in:
shell> echo "DEV12390 > /proc/fs/nfsd/nlm_unlock;

or allow individual grace period of 10 seconds as:
shell> echo "1234@10" > nlm_set_grace_for_fsid

With above said, some of the following flow confuses me ... comment 
inlined as below ..

>It works like this:
>
>  We have a module parameter for lockd something like
>  "virtual_server".
>  If that is set to 0, none of the following changes are effective.
>  If it is set to 1:
>  
>
ok with me ...

>   The destination address for any lockd request becomes part of the
>   key to find the nsm_handle.
>  
>

As explained above, the address along can't guarantee the associated 
locks get cleaned up for one particular filesystem.

>   The my_name field in SM_MON requests and SM_UNMON requests is set
>   to a textual representation of that destination address.
>  
>

That's what the current patch does.

>   The reply to SM_MON (currently completely ignored by all versions
>   of Linux) has an extra value which indicates how many more seconds
>   of grace period there is to go.  This can be stuffed into res_stat
>   maybe.
>   Places where we currently check 'nlmsvc_grace_period', get moved to
>   *after* the nlmsvc_retrieve_args call, and the grace_period value
>   is extracted from host->nsm.
>  
>
ok with me but I don't see the advantages though ?

>  This is the full extent of the kernel changes.
>
>  To remove old locks, we arrange for the callbacks registered with
>  statd for the relevant clients to be called.
>  To set the grace period, we make sure statd knows about it and it
>  will return the relevant information to lockd.
>  To notify clients of the need to reclaim locks, we simple use the
>  information stored by statd, which contains the local network
>  address.
>  
>

I'm lost here... help ?

>The only aspect of this that gives me any cause for concern is
>overloading the return value for SM_MON.  Possibly it might be cleaner
>to define an SM_MON2 with different args or whatever.
>As this interface is entirely local to the one machine, and as it can
>quite easily be kept back-compatible, I think the concept is fine.
>  
>
Agree !

>Statd would need to pass the my_name field to the ha callout rather
>than replacing it with "127.0.0.1", but other than that I don't think
>any changes are needed to statd (though I haven't thought through that
>fully yet).
>  
>

That's the current patch does.

>Comments?
>
>
>  
>
I feel we're in the loop again... If there is any way I can shorten this 
discussion, please do let me know.

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
