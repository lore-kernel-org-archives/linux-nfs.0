From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or	"vers=4"
	option are set (vers-02)
Date: Fri, 28 Aug 2009 12:35:29 -0400
Message-ID: <4A980751.7070206@RedHat.com>
References: <B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com>
	<4A954FBF.3030606@RedHat.com>
	<23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>
	<4A956BF2.6000902@RedHat.com>
	<F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
	<4A95760C.9000604@RedHat.com>
	<B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
	<1251316764.5226.21.camel@heimdal.trondhjem.org>
	<4A9694D2.2030205@RedHat.com>
	<4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
	<20090828161256.GA2859@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090828161256.GA2859@infradead.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/28/2009 12:12 PM, Christoph Hellwig wrote:
> On Thu, Aug 27, 2009 at 01:32:09PM -0400, Chuck Lever wrote:
>>>>> about making that more feasible.
>>>>
>>>> Just look at what we're already doing for NFSv4. Inside nfs4_get_sb, 
>>>> we
>>>> basically do a kernel mount in order to get the real super block. We
>>>> then simply have to attach it to the vfsmount that the sys_mount()  
>>>> call
>>>> passed down to us.
>>> Well its not nfs4_get_sb() that would have to change its nfs_get_sb()
>>> that would have to do an nfs4 mount after it discovered the -o vers=4.
>>> It would get very messy very quickly for absolutely no reason since
>>> the propose mount patch is straightforward, it works and better yet
>>> its done! ;-)
>>
>> Right now we are only speculating that doing this in the kernel will not 
>> be straightforward.  You say it will be unbearably ugly, and Trond says 
>> it should be simple.  He said - he said.  Why not try it and find out?
> 
> It's actually trivial.  The file_system_type does not have much meaning
> at all, it contains very little information:
Question... How are will it be to back out of this? Meaning the
kernel tries a v4 mount only to see the server does not support v4
or for some other recoverable error and then has to restart back
down the mount NFS again... This is very fairly trivial in user space...  

steved.
