From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Subject: Re: Option noac not working correctly?
Date: Wed, 18 Mar 2009 17:42:09 +0100
Message-ID: <49C12461.8040001@bull.net>
References: <49C106DD.2080008@bull.net>
	<1237389003.7275.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1237389003.7275.9.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Wed, 2009-03-18 at 15:36 +0100, Diego Moreno wrote:
>> Hello everyone,
>>
>> I've been testing the noac mount option in several kernels (2.6.27.10, 
>> 2.6.29-rc8) for NFSv3 and NFSv4. The next commands do not work properly:
>>
>> rm -f /export/B; ls -l /tmp/nfs_client_tcp/B ; uname -a > /export/B; ls 
>> -l /tmp/nfs_client_tcp/B
>>
>> Result is usually:
>>
>> ls: /tmp/nfs_client_tcp/B: No such file or directory
>> ls: /tmp/nfs_client_tcp/B: No such file or directory
>>
>> Actually the result should be always:
>>
>> ls: /tmp/nfs_client_tcp/B: No such file or directory
>> -rw-r--r-- 1 root root 89 Mar 18 14:02 /tmp/nfs_client_tcp/B
>>
>> Network traces show me that client is not making any lookup in the 
>> server for the second 'ls'. A client with noac option should always make 
>> a lookup on server, isn't it?
>>
>> My /etc/exports file:
>>
>> /export  *(rw,fsid=0,insecure,no_subtree_check)
>>
>> Relevant information from cat /proc/mounts:
>>
>> pwrd:/ /tmp/nfs_client_tcp nfs4 
>> rw,sync,vers=4,rsize=1048576,wsize=1048576,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,nointr,noac,proto=tcp,timeo=600,retrans=2,sec=sys
>>
>> NFS debug trace of the second ls command:
>>
>> NFS call  access
>> NFS: nfs_update_inode(0:17/2 ct=2 info=0x6)
>> NFS reply access: 0
>> NFS: permission(0:17/2), mask=0x1, res=0
>> NFS: revalidating (0:17/2)
>> NFS call  getattr
>> NFS reply getattr: 0
>> NFS: nfs_update_inode(0:17/2 ct=2 info=0x6)
>> NFS: nfs3_forget_cached_acls(0:17/2)
>> NFS: (0:17/2) revalidation complete
>> NFS: nfs_lookup_revalidate(/B) is valid
>> NFS: dentry_delete(/B, 8)
>>
>> Is there anything I'm not doing well? Is this a known bug for the last 
>> kernel version? Thanks,
> 
> The above behaviour is perfectly correct _if_ the mtime
> on /tmp/nfs_client_tcp doesn't change between your 'rm' and the creation
> of B. Given that most Linux filesystems have poor (1 second) resolution
> on mtime, then for it not to change in the above test is an extremely
> likely event.
> 
> Note that there is a better option for controlling lookup behaviour in
> newer kernels: -olookupcache=all or -olookupcache=positive should both
> cause your test above to pass irrespective of whether or not mtime
> changed.
> 
> Trond

Thanks for your quick reply Trond. I've seen the only way to pass my 
test is using (for kernel 2.6.29-rc8): -olookupcache=positive,noac. If I 
use -olookupcache=positive or -olookupcache=all or 
-olookupcache=all,noac my test doesn't pass.

BTW, is there any way of passing this test for a kernel like 2.6.27 
(there is no lookupcache mount option). In kernels like 2.6.19 or 2.6.20 
I think I passed my test just using noac option. These kernels where the 
first kernels with the patch (commit 
b0b539739fe9b7d75002412a787cfdf4efddbc33) treating the special case of 
nfsi->attrtimeo==0. That means 'noac' or/and actimeo=0 mount options.

Thanks,

Diego
