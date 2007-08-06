From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Mon, 6 Aug 2007 12:09:53 -0400
Message-ID: <20070806160953.GA8734@fieldses.org>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org> <46B7410A.3050202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II59V-0002UR-6d
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 09:09:53 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II59Y-0003H3-TJ
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 09:09:57 -0700
In-Reply-To: <46B7410A.3050202@redhat.com>
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

On Mon, Aug 06, 2007 at 11:40:58AM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> On Fri, Aug 03, 2007 at 03:29:10PM -0400, Peter Staubach wrote:
>>> @@ -203,31 +203,15 @@ encode_fattr3(struct svc_rqst *rqstp, __
>>>  static __be32 *
>>>  encode_saved_post_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh 
>>> *fhp)
>>>  {
>>> -	struct inode	*inode = fhp->fh_dentry->d_inode;
>>> +	if (!fhp->fh_post_saved) {
>>> +		*p++ = xdr_zero;
>>> +		return p;
>>> +	}
>>>     
>>
>> The caller, encode_wcc_data(), already did this check.
>
> True.  What a twisty maze of small passages, all alike.
>
> The current algorithms don't look quite right to me.  I don't
> think that it is valid to return a post_op_attr, which is not
> atomic w.r.t. the operation, even when not returning a pre_op_attr.
> Perhaps a little more cleanup might be good.  I will look into
> this.

I *think* the current code is correct, but I agree that it's worth
another check--thanks!

I've also never been really fond of the combined handling of fh_{un}lock
functions that combine the locking and attribute gathering.  But maybe
it's just me--I haven't really thought about that code.

>> Dumb question: I assume it's always legal to call ->getattr while
>> holding the i_mutex?
>>   
>
> Not so dumb, and I couldn't find an answer to that, either way.
> I couldn't find any reason why it would be illegal, but neither
> did I find explicit reasons for why it would be legal.
>
> Does anyone else know?  This gets into the lack of complete
> definition for the virtual file system layer...

There's a useful file Documentation/filesystems/Locking.  It has a table
that explains which operations take the i_mutex and which don't.  I
assume that a "no" in the table means that function isn't usually called
with the i_mutex, not that it necessarily *must* not be.  But I could be
wrong.

That table could use a caption....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
