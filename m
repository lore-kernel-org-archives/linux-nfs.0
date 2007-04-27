From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Thu, 26 Apr 2007 22:24:45 -0400
Message-ID: <46315EED.9020103@redhat.com>
References: <46156F3F.3070606@redhat.com>	<4625204D.1030509@redhat.com>	<17959.5245.635902.823441@notabene.brown>	<462D79F0.4060800@redhat.com>	<17965.39683.396108.623418@notabene.brown>	<46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhFyV-0002UO-Jt
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 19:14:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhFyX-000781-W7
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 19:14:22 -0700
In-Reply-To: <17968.15370.88587.653447@notabene.brown>
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

>On Thursday April 26, wcheng@redhat.com wrote:
>  
>
>>A convincing argument... unfortunately, this happens to be a case where 
>>we need to protect server from client's misbehaviors. For a local 
>>filesystem (ext3), if any file reference count is not zero (i.e. some 
>>clients are still holding the locks), the filesystem can't be 
>>un-mounted. We would have to fail the failover to avoid data corruption.
>>    
>>
>
>I think this is a tangential problem.
>"removing locks held by troublesome clients so that I can unmount my
>filesystem" is quite different from "remove locks held by client
>clients using virtual-NAS-foo so they can be migrated".
>  
>
The reason to unmount is because we want to migrate the virtual IP. IMO 
they are the same issue but it is silly to keep fighting about this. In 
any case, one interface is better than two, if you allow me to insist on 
this.

So how about we do RPC call to lockd to tell it to drop the locks owned 
by the client/local-IP pair as you proposed, *but* add an "OR" with fsid 
to fool proof the process ? Say something like this:

RPC_to_lockd_with (client_host, client_ip, fsid);
if ((host == client_host && vip == client_ip) ||
(get_fsid(file) == client_fsid))
drop_the_locks();

This logic (RPC to lockd) will be triggered by a new command added to 
nfs-util package.

If we can agree on this, the rest would be easy. Done ?

-- Wendy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
