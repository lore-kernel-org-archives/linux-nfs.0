From: Steve Dickson <SteveD@redhat.com>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: Tue, 29 Apr 2003 17:18:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAEEC0D.6040006@RedHat.com>
References: <3EAE956E.9080205@RedHat.com> <shs4r4h5l52.fsf@charged.uio.no>	<3EAEC774.20402@RedHat.com> <shssms1ozz6.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AcUO-0008DA-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 14:18:12 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:

>     > So I'm just curious, why (from a protocol purest standpoint)
>     > its not being used... and if it ever was used, what were the
>     > results...
>
>I'm not sure I understand the question. In which case do you think we
>should be using FSINFO/STATFS (but are currently not doing so)?
>
In the linux-2.4.21-08-pathconf.dif patch, nfs_proc_fsinfo()
does a rpc_call(NFSPROC_STATFS) call and then fill in
the nfs_fsinfo structure with constants and values returned
in the nfs2_statfs structure.

I'm just wondering why nfs_proc_fsinfo() doesn't do a
rpc_call(NFSPROC_FSINFO) which would fill the nfs_fsinfo
structure with the values from the server. Of course these
values would have to be check for sanity... I just seems to
me that would be good information to to have on hand...

SteveD.





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
