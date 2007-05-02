From: Peter Staubach <staubach@redhat.com>
Subject: Re: Understanding nfsstat output
Date: Wed, 02 May 2007 16:30:32 -0400
Message-ID: <4638F4E8.6030904@redhat.com>
References: <953249.36987.qm@web56613.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjLTB-0006wR-6M
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 13:30:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HjLTD-000145-5M
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 13:30:39 -0700
In-Reply-To: <953249.36987.qm@web56613.mail.re3.yahoo.com>
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

AK wrote:
> Hello everyone!
>  
> I am trying to understand the output of nfsstat to better understand 
> and tweak NFS performance for our machines.
>  
> Following is the output from our Solaris 9, NFSv3 running server:
>  
> I am concerned about the "badcalls" for "Server nfs" output, is this 
> normal or something is wrong. We have some of our clients mounting the 
> exported File system with rsize & wsize = 32K,  Could this be the 
> problem, is there a way to narrow it down?
>  
> Any feedback is greatly appreciated!
>  
> ~thanks ~al
>  
> # nfsstat -s
>  
> Server rpc:
> Connection oriented:
> calls        badcalls     nullrecv     badlen       xdrcall      dupchecks
> 101090599    0            0            0            0            62704096
> dupreqs
> 7038
> Connectionless:
> calls        badcalls     nullrecv     badlen       xdrcall      dupchecks
> 17121084     0            0            0            0            7028935
> dupreqs
> 69076
>  
> Server nfs:
> calls        badcalls
> 118266383    57138
> Version 2: (0 calls)
> null         getattr      setattr      root         lookup       readlink
> 0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
> read         wrcache      write        create       remove       rename
> 0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
> link         symlink      mkdir        rmdir        readdir      statfs
> 0 0%         0 0%         0 0%         0 0%         0 0%         0 0%
> Version 3: (117965148 calls)
> null         getattr      setattr      lookup       access       readlink
> 1 0%         185486 0%    1906 0%      41482 0%     24091 0%     487 0%
> read         write        create       mkdir        symlink      mknod
> 47680376 40% 69594128 58% 2516 0%      2 0%         80 0%        0 0%
> remove       rmdir        rename       link         readdir      
> readdirplus
> 1658 0%      4 0%         126 0%       7 0%         1890 0%      2726 0%
> fsstat       fsinfo       pathconf     commit
> 222331 0%    9 0%         2 0%         205840 0%
>  
> Server nfs_acl:
> Version 2: (0 calls)
> null         getacl       setacl       getattr      access
> 0 0%         0 0%         0 0%         0 0%         0 0%
> Version 3: (111 calls)
> null         getacl       setacl
> 0 0%         73 65%       38 34%
>
> ------------------------------------------------------------------------

I would suggest asking the Solaris folks for the interpretation for the
output fields in the Solaris version of nfsstat.

That said, the number appears to be a small percentage of the total
number of calls as to not worry very much about.

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
