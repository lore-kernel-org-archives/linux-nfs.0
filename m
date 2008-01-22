From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 20:30:33 +0200
Message-ID: <47963649.9020502@panasas.com>
References: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>	
	<1201013438.30335.5.camel@heimdal.trondhjem.org>	
	<47960DA7.1010203@panasas.com>	
	<126C1947-AB76-4C93-95F7-2787081DBEC3@oracle.com>
	<1201025443.30335.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1201025443.30335.29.camel@heimdal.trondhjem.org>
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

On Jan. 22, 2008, 20:10 +0200, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2008-01-22 at 11:58 -0500, Chuck Lever wrote:
>> Hi Benny-
>>
>> On Jan 22, 2008, at 10:37 AM, Benny Halevy wrote:
>>> On Jan. 22, 2008, 16:50 +0200, Trond Myklebust  
>>> <Trond.Myklebust@netapp.com> wrote:
>>>> On Tue, 2008-01-22 at 16:28 +0200, Benny Halevy wrote:
>>>>> Otherwise e.g., NFS_SERVER(&nfsi->vfs_inode) does not compile.
>>>>>
>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>> ---
>>>>>  include/linux/nfs_fs.h |    4 ++--
>>>>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>>>>
>>>>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>>>>> index 0477a4c..5a5d3fe 100644
>>>>> --- a/include/linux/nfs_fs.h
>>>>> +++ b/include/linux/nfs_fs.h
>>>>> @@ -221,10 +221,10 @@ static inline struct nfs_inode *NFS_I 
>>>>> (struct inode *inode)
>>>>>  {
>>>>>  	return container_of(inode, struct nfs_inode, vfs_inode);
>>>>>  }
>>>>> -#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
>>>>> +#define NFS_SB(s)		((struct nfs_server *)((s)->s_fs_info))
>>>>>
>>>>>  #define NFS_FH(inode)			(&NFS_I(inode)->fh)
>>>>> -#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
>>>>> +#define NFS_SERVER(inode)		(NFS_SB((inode)->i_sb))
>>>>>  #define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
>>>>>  #define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
>>>>>  #define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
>>>> They should really be converted into inlined functions.
>>>>
>>>> Cheers
>>>>   Trond
>>> Agreed.  How about the following:
>>> ---
>>> [PATCH] nfs: convert NFS_*(inode) helpers to static inline
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> (Patch passes all connectathon tests)
>>>
>>>  fs/nfs/dir.c           |    8 ++--
>>>  fs/nfs/inode.c         |    8 ++--
>>>  fs/nfs/read.c          |    2 +-
>>>  include/linux/nfs_fs.h |   78 ++++++++++++++++++++++++++++++++++++ 
>>> +----------
>>>  4 files changed, 70 insertions(+), 26 deletions(-)
>>>
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index f697b5c..7b64c22 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -192,7 +192,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t  
>>> *desc, struct page *page)
>>>  		/* We requested READDIRPLUS, but the server doesn't grok it */
>>>  		if (error == -ENOTSUPP && desc->plus) {
>>>  			NFS_SERVER(inode)->caps &= ~NFS_CAP_READDIRPLUS;
>>> -			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
>>> +			clear_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));
>> Since you already have NFS_USE_READDIRPLUS defined below, maybe the  
>> equivalent clear_bit functionality can also be an inlined function.   
>> It is even used in more than one place.
> 
> I disagree. The inlined wrapper adds nothing but obfuscation in this
> case. It would be different if you needed memory barriers, but that is
> not the case here.
> 
>> I feel like NFS_FLAGSP (returning a pointer) is somewhat awkward, but  
>> that's just my taste I suppose.
> 
> Ideally, we should get rid of NFS_FLAGS()/NFS_FLAGSP(). That too is just
> obfuscating the code for no good reason.

I completely agree that NFS_FLAGSP is ugly.
Initially I thought of changing &NFS_FLAGS(inode) to &NFS_I(inode)->flags
and get rid of NFS_FLAGS, but I deferred to the most minimal change.
Let me know if you want me to do that.

> 
>>>  static void nfs_invalidate_inode(struct inode *inode)
>>>  {
>>> -	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
>>> +	set_bit(NFS_INO_STALE, NFS_FLAGSP(inode));
>> Likewise for NFS_INO_STALE... A separate inline for setting  
>> NFS_INO_STALE might be a little nicer.
> 
> Not an inline. Just convert the existing nfs_invalidate_inode() into an
> nfs_invalidate_inode_locked(), and add a version that takes the lock.

I'm not sure I follow you...  All it does is setting the NFS_INO_STALE
bit and calling nfs_zap_caches_locked.  What use case is there for 
the unlocked case?

> 
>>>  	nfs_zap_caches_locked(inode);
>>>  }
>>>
>>> @@ -229,7 +229,7 @@ nfs_init_locked(struct inode *inode, void *opaque)
>>>  	struct nfs_find_desc	*desc = (struct nfs_find_desc *)opaque;
>>>  	struct nfs_fattr	*fattr = desc->fattr;
>>>
>>> -	NFS_FILEID(inode) = fattr->fileid;
>>> +	set_nfs_fileid(inode, fattr->fileid);
>>>  	nfs_copy_fh(NFS_FH(inode), desc->fh);
>>>  	return 0;
>>>  }
>>> @@ -291,7 +291,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh  
>>> *fh, struct nfs_fattr *fattr)
>>>  			inode->i_fop = &nfs_dir_operations;
>>>  			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
>>>  			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
>>> -				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
>>> +				set_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));
>> And for setting NFS_INO_ADVISE_RDPLUS.
> 
> Again, why?

The only good reason I can think of is abstracting the API to allow a different
implementation in the future, but I see little benefits as for style or readability.

> 
>>> (inode)))
>>> +static inline struct nfs_fh *NFS_FH(const struct inode *inode)
>>> +{
>>> +	return &NFS_I(inode)->fh;
>>> +}
>> Since these are no longer macros, maybe we should change the case of  
>> their names too.  I realize NFS_USE_READDIRPLUS has set a precedent,  
>> but perhaps it's an ugly one we should fix now.
> 
> Changing NFS_I() would break with a common practice that is shared with
> almost all filesystems. See, for instance, EXT3_I(), REISERFS_I(),
> XFS_I(),...
> 
> 
> Trond
