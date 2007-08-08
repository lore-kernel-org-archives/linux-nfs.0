From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Wed, 08 Aug 2007 16:07:37 -0400
Message-ID: <46BA2289.5060902@redhat.com>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIros-0008J3-NB
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 13:07:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIrow-0003LT-GA
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 13:07:54 -0700
In-Reply-To: <20070804223256.GA1155@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

J. Bruce Fields wrote:
> On Fri, Aug 03, 2007 at 03:29:10PM -0400, Peter Staubach wrote:
>   
>> Hi.
>>
>> Attached is a patch to modify the NFS server code to support
>> 64 bit ino's, as appropriate for the system and the NFS
>> protocol version.
>>
>> The gist of the changes is to query the underlying file system
>> for attributes and not just to use the cached attributes in the
>> inode.  For this specific purpose, the inode only contains an
>> ino field which unsigned long, which is large enough on 64 bit
>> platforms, but is not large enough on 32 bit platforms.
>>     
>
> Thanks!
>
>   
>> @@ -203,31 +203,15 @@ encode_fattr3(struct svc_rqst *rqstp, __
>>  static __be32 *
>>  encode_saved_post_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
>>  {
>> -	struct inode	*inode = fhp->fh_dentry->d_inode;
>> +	if (!fhp->fh_post_saved) {
>> +		*p++ = xdr_zero;
>> +		return p;
>> +	}
>>     
>
> The caller, encode_wcc_data(), already did this check.
>
>   
>>  	/* Attributes to follow */
>>  	*p++ = xdr_one;
>>  
>> -	*p++ = htonl(nfs3_ftypes[(fhp->fh_post_mode & S_IFMT) >> 12]);
>> -	*p++ = htonl((u32) fhp->fh_post_mode);
>> -	*p++ = htonl((u32) fhp->fh_post_nlink);
>> -	*p++ = htonl((u32) nfsd_ruid(rqstp, fhp->fh_post_uid));
>> -	*p++ = htonl((u32) nfsd_rgid(rqstp, fhp->fh_post_gid));
>> -	if (S_ISLNK(fhp->fh_post_mode) && fhp->fh_post_size > NFS3_MAXPATHLEN) {
>> -		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
>> -	} else {
>> -		p = xdr_encode_hyper(p, (u64) fhp->fh_post_size);
>> -	}
>> -	p = xdr_encode_hyper(p, ((u64)fhp->fh_post_blocks) << 9);
>> -	*p++ = fhp->fh_post_rdev[0];
>> -	*p++ = fhp->fh_post_rdev[1];
>> -	p = encode_fsid(p, fhp);
>> -	p = xdr_encode_hyper(p, (u64) inode->i_ino);
>> -	p = encode_time3(p, &fhp->fh_post_atime);
>> -	p = encode_time3(p, &fhp->fh_post_mtime);
>> -	p = encode_time3(p, &fhp->fh_post_ctime);
>> -
>> -	return p;
>> +	return encode_fattr3(rqstp, p, fhp, &fhp->fh_post_attr);
>>     
>
> Is there a problem with the lease_get_mtime() call in encode_fattr3()?
> It looks like that could return the current time rather than the time
> that was supposedly atomic with respect to the operation.
>
>   

I'm testing a new version of the patch, which addresses this
issue, but then I got to wondering, what is lease_get_mtime()
really for and is it solving a real problem, and if so, is it
solving it in a reasonable fashion?

It appears to me that it is used to detect when an application
on the server has acquired an exclusive lease for a file and
may be modifying it, but without informing the kernel.  If it
was informing the kernel, then the mtime would be updated.

NFS doesn't support leases like this, so it would need to be
an application running on the server, either as a standalone
application or as a server for some other service.

Outside of delegations, we don't support anything else like
this, so why is this a special case?  Was there a real world
problem that this solved?

And, why does it matter whether the attributes are being
returned via GETATTR, via a post_op_attr, or via a post_op_attr
as part of a wcc_data?  The first two cases invoke lease_get_mtime(),
while the third does not.  Could this not lead to time jumping
around on a particular file, forwards and backwards?

    Thanx...

       ps

> Dumb question: I assume it's always legal to call ->getattr while
> holding the i_mutex?
>
> --b.
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
