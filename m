From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
	client --revised
Date: Mon, 9 Feb 2009 12:11:31 -0500
Message-ID: <20090209171131.GG10297@fieldses.org>
References: <200901121216.n0CCGYMx001106@acsinet13.oracle.com> <20090204234924.GE20917@fieldses.org> <498BA760.2090603@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41173 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbZBIRL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 12:11:27 -0500
In-Reply-To: <498BA760.2090603@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 06, 2009 at 10:58:40AM +0800, Wengang Wang wrote:
> J. Bruce Fields wrote:
>> On Mon, Jan 12, 2009 at 08:14:46PM +0800, wengang wang wrote:
>>> for descriptions for the problem and solution please see my former post with
>>> Subject "nfsd(v2/v3): fix the failure of creation from HPUX client".
>>
>> Could you just repeat that introduction each time?  I want to commit it
>> with the patch, and that will save me some work hunting down the old
>> email.
>
> Sorry.
> OK, will follow that for later patch postings.

Thanks.

>> It seems that all newfile does is tell us whether the net thing that was
>> created is a regular file or not.  Does it even make sense to set size
>> on other objects?  If not, then why not just make this:
>>
>> 	if (iap->ia_size == 0)
>> 		iap->ia_valid &= ~ATTR_SIZE;
>>
>> and remove the need for "newfile"?
>>
>
> I want it tell us whether it's new created(vfs_create()ed) file or a  
> already existing one to be truncated.
> the later is in case of
>
> if (dchild->d_inode) {
> 	...
> 	switch (createmode) {
> 	case NFS3_CREATE_UNCHECKED:
> 		...
> 		else {
> 			...
> 			goto set_attr;
> 	
> I think we should resize file to zero for the truncating case.
> maybe I'm wrong somethere?

OK, sorry, you're right, I missed the "goto" in the nfsd_create_v3()
case.  And in other cases we still want the permission check to handle,
I guess.  Fair enough.

> From a quick look at nfsd_setattr() it appears
>> it's doing all permissions checks with NFSD_MAY_OWNER_OVERRIDE, which
>> should allow the setting of size, even in the case of mode 0, as long as
>> the caller is the owner of the new file.  
>
> I think you are mentioning the call nfsd_permission() in nfsd_setattr().
> if you are, the call is under a condition of
> 	if (iap->ia_size < inode->i_size) {
> in this case iap->ia_size(being 0) equals to inode->i_size, so  
> nfsd_permission() is not called.
>
> and from above call trace, it's not within nfsd_permission() where error  
> returns.

Yeah, OK, and OWNER_OVERRIDE isn't really what we want in this case
anyway, since the client doesn't know whether the operation will be a
create and so can't check these permissions for us as it can in the case
of writes.

That being the case, I admit, your first attempt looks simpler.  Could
you just do that, but move the common code (and comment) into a helper
function called from the same two places?

--b.
