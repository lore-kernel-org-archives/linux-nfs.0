From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Thu, 26 Apr 2007 00:35:13 -0400
Message-ID: <46302C01.2060500@redhat.com>
References: <46156F3F.3070606@redhat.com>	<4625204D.1030509@redhat.com>	<17959.5245.635902.823441@notabene.brown>	<462D79F0.4060800@redhat.com>
	<17965.39683.396108.623418@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgvXA-0007MR-1u
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:25:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgvXC-0001RW-8x
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:24:46 -0700
In-Reply-To: <17965.39683.396108.623418@notabene.brown>
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

>On Monday April 23, wcheng@redhat.com wrote:
>  
>
>>Neil Brown wrote:
>>
>>[snip]
>>
>>             We started the discussion using network interface (to drop 
>>the locks) but found it wouldn't work well on local filesytems such as 
>>ext3. There is really no control on which local (sever side) interface 
>>NFS clients will use (shouldn't be hard to implement one though). When 
>>the fail-over server starts to remove the locks, it needs a way to find 
>>*all* of the locks associated with the will-be-moved partition. This is 
>>to allow umount to succeed. The server ip address alone can't guarantee 
>>that. That was the reason we switched to fsid. Also remember this is NFS 
>>v2/v3 - clients have no knowledge of server migration.
>>    
>>
>[snip]
>
>So it seems to me we do know exactly the list of local-addresses that
>could possibly be associated with locks on a given filesystem.  They
>are exactly the IP addresses that are publicly acknowledged to be
>usable for that filesystem.
>And if any client tries to access the filesystem using a different IP
>address then they are doing the wrong thing and should be reformatted.
>  
>

A convincing argument... unfortunately, this happens to be a case where 
we need to protect server from client's misbehaviors. For a local 
filesystem (ext3), if any file reference count is not zero (i.e. some 
clients are still holding the locks), the filesystem can't be 
un-mounted. We would have to fail the failover to avoid data corruption.

>Maybe the idea of using network addresses was the first suggestion,
>and maybe it was rejected for the reasons you give, but it doesn't
>currently seem like those reasons are valid.  Maybe those who proposed
>those reasons (and maybe that was me) couldn't see the big picture at
>the time...
>  
>

This debate has been (so far) tolerable and helpful - so I'm not going 
to comment on this paragraph :) ... But I have to remind people my first 
proposal was adding new flags into export command (say "exportfs -ud" to 
unexport+drop locks, and "exportfs -g" to re-export and start grace 
period). Then we moved to "echo network-addr into procfs", later 
switched to "fsid" approach. A very long journey ...

>  
>
>>>  The reply to SM_MON (currently completely ignored by all versions
>>>  of Linux) has an extra value which indicates how many more seconds
>>>  of grace period there is to go.  This can be stuffed into res_stat
>>>  maybe.
>>>  Places where we currently check 'nlmsvc_grace_period', get moved to
>>>  *after* the nlmsvc_retrieve_args call, and the grace_period value
>>>  is extracted from host->nsm.
>>> 
>>>
>>>      
>>>
>>ok with me but I don't see the advantages though ?
>>    
>>
>
>So we can have a different grace period for each different 'host'.
>  
>

IMHO, having grace period for each client (host) is overkilled.

> [snip]
>
>Part of unmounting the filesystem from Server A requires getting
>Server A to drop all the locks on the filesystem.  We know they can
>only be held by client that sent request to a given set of IP
>addresses.   Lockd created an 'nsm' for each client/local-IP pair and
>registered each of those with statd.  The information registered with
>statd includes the details of an RPC call that can be made to lockd to
>tell it to drop all the locks owned by that client/local-IP pair.
>
>The statd in 1.1.0 records all this information in the files created
>in /var/lib/nfs/sm (and could pass it to the ha-callout if required).
>So when it is time to unmount the filesystem, some program can look
>through all the files in nfs/nm, read each of the lines, find those
>which relate to any of the local IP address that we want to move, and
>initialiate the RPC callback described on that line.  This will tell
>lockd to drop those lockd.  When all the RPCs have been sent, lockd
>will not hold any locks on that filesystem any more.
>  
>

Bright idea ! But doesn't solve the issue of misbehaved clients who come 
in from un-wanted (server) interfaces. Does it ?

>
>[snip]
>I feel it has taken me quite a while to gain a full understanding of
>what you are trying to achieve.  Maybe it would be useful to have a
>concise/precise description of what the goal is.
>I think a lot of the issues have now become clear, but it seems there
>remains the issue of what system-wide configurations are expected, and
>what configuration we can rule 'out of scope' and decide we don't have
>to deal with.
>  
>
I'm trying to do the write-up now. But could the following temporarily 
serve the purpose ? What is not clear from this thread of discussion?

http://www.redhat.com/archives/linux-cluster/2006-June/msg00050.html


-- Wendy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
