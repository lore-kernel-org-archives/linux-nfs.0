From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 30 Aug 2004 11:03:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413341B8.9090504@steeleye.com>
References: <4124DB86.9060505@steeleye.com> <16677.22269.988036.787320@cse.unsw.edu.au> <412E1C10.5020703@steeleye.com> <20040827073049.GA23324@suse.de> <412F3362.5040707@steeleye.com> <20040830082510.GD28454@suse.de> <20040830101947.GE5745@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Olaf Kirch <okir@suse.de>, Neil Brown <neilb@cse.unsw.edu.au>,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1nk9-0003xo-CS
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:06:49 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C1nk7-0004X7-HJ
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:06:49 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040830101947.GE5745@sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Greg Banks wrote:
> On Mon, Aug 30, 2004 at 10:25:11AM +0200, Olaf Kirch wrote:

>>Doesn't a HA NFS deployment require a shared disk anyway?
> 
> 
> Shared data disks, not a shared root disk.
> 
> 
>>Why not just
>>move /var/lib/nfs to this file system so it gets shared the same way you
>>share the rest of your data?
> 
> 
> This would have to be done manually on a per-site basis because you
> can't predict where the mountpoint of any particular shared disk will
> be when NFS starts.  So packaging an HA solution based on that
> arrangement would be a mite tricky.

You also cannot support active/active configurations when /var/lib/nfs 
is linked (or mounted) to a shared location. That is our primary reason 
for needing the callouts. Specifically, in order to support 
active/active configurations, either you've got to broadcast the 
information to all cluster nodes or you've got to "shadow" the 
/var/lib/nfs contents on shared storage.

--
Paul


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
