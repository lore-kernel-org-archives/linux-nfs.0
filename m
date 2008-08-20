From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Wed, 20 Aug 2008 16:08:27 -0400
Message-ID: <20080820200827.GC21226@fieldses.org>
References: <20080814223028.GN23859@fieldses.org> <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045AbYHTUI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 16:08:29 -0400
In-Reply-To: <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 15, 2008 at 12:59:09PM -0400, Chuck Lever wrote:
> On Aug 14, 2008, at 6:30 PM, J. Bruce Fields wrote:
>> I was looking back at this bug with the misparsing of
>> (non-mull-terminated) fs_locations attributes.  Thanks to the work on
>> nfs_parse_server_address, etc., we can now also more easily support  
>> ipv6
>> addresses here.  But I got lost in the usual maze of twisty struct
>> sockaddr_*'s, all alike.  Is this right?  Does any of it need to be
>> under CONFIG_IPV6?  Is there a simpler way?
>
> The use of the new address parser looks correct, but your string  
> handling needs work.  :-)
>
> Comments below...

Pffft.  My hope that someone else would pick this up for me was
obviously fantasy. OK, thanks for comments:

>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>> index b112857..c0f5191 100644
...
>> +			if (memchr(buf->data, '%', buf->len))
>> +				goto next;
>
> Why are you looking for a '%' ?

Would it have been clearer if I'd moved the IPV6_SCOPE_DELIMITER define
to a common header?  I don't think that has any place in the nfs
protocol.  And we've got less trust in the address we're parsing here
(which came across the wire) then we would in a mount commandline.

>
>> +			nfs_parse_ip_address(buf->data, buf->len,
>> +					mountdata.addr, &mountdata.addrlen);
>
> Now what's so hard about that?  :-)

Yeah, yeah....

>>
>> +			switch (mountdata.addr->sa_family) {
>> +			case AF_UNSPEC:
>> +				goto next;
>> +			case AF_INET:
>> +				((struct sockaddr_in *)&addr)->sin_port =
>> +							htons(NFS_PORT);
>> +				break;
>> +			case AF_INET6:
>> +				((struct sockaddr_in6 *)&addr)->sin6_port =
>> +							htons(NFS_PORT);
>> +				break;
>> +			}
>
> It might be cleaner to pull the whole while {} loop into a separate  
> function.  I didn't look closely enough to see if this would be easy.

Yup, done.

>
> At least here, you could set the port in a small helper function, and  
> then put an "if (unlikely(family == AF_UNSPEC)) goto next;" just after  
> the call to nfs_parse_ip_address, to save all the crazy indenting.  If  
> we ever create a global helper to manage AF-agnostic port setting, that 
> would make it easier to use here if the AF_UNSPEC check were separate.
>
> In fact, as part of this patch you could add a static inline helper in  
> fs/nfs/internal.h to do the port setting.  That can be shared between  
> fs/nfs/super.c and fs/nfs/nfs4namespace.c.
>
> Arguably the addition of the AF_UNSPEC check in the switch statement is 
> an optimization that is slightly confusing.  You are checking for  
> AF_UNSPEC to see if you should continue the loop, but the other cases  
> are for setting a port; two entirely different purposes.
>
> It would be more precise structuring to keep these two separate, even  
> though it might add an extra conditional branch.  This makes it easier  
> to spot the loop condition expressions.

Agreed, done.

>
>> +
>> +			mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
>> +			mountdata.hostname[buf->len] = 0;
>
> The usual practice is to use '\0' here since it is a character array; 0 
> is an int, not a character, so this does an implicit cast.  Harmless, but 
> using a character constant is more precise.

OK, done.

> But I'm not sure why you are not using location->servers[s].data (or  
> buf->data).

The mountdata->hostname field needs a null terminated string.

> You kmalloc a buffer for hostname, but aren't setting it to 
> anything.  Did you mean kstrndup?

Whoops.  Actually, since the code tries to allocate memory for us at the
start, it probably makes more sense just to use a piece of that memory;
done.

>> 			snprintf(page, PAGE_SIZE, "%s:%s",
>> 					mountdata.hostname,
>> 					mountdata.mnt_path);
>
> For snprintf, you can specify the length of the string with a "%.*s"  
> format.  Then you pass buf->len and buf->data (in that order) to it.   
> That way you can print a non-NUL-terminated string safely.  That should 
> make any memory allocation or string copying unnecessary here.

No, mountdata.hostname independently still needs to be null terminated.

>
>> 			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
>> +			kfree(mountdata.hostname);
>
> mountdata.hostname is used in other places... I don't think you can just 
> free it here.  Another reason to use a pointer to location- 
> >servers[s].data.

That memory will go away soon, too.  The previous code is actually just
pointing to data on the stack.  So it's the callee's responsibility to
make any copies it needs before returning.

> If location->servers[s].data isn't always NUL-terminated, you might make 
> mountdata.hostname an nfs4_string so it carries the string length with 
> it; the other users of mountdata.hostname can then see the length.

That's passed around a lot and the assumption that it's null terminated
appears to be common (and convenient).

>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -444,6 +444,8 @@ extern const struct inode_operations  
>> nfs_referral_inode_operations;
>> extern int nfs_mountpoint_expiry_timeout;
>> extern void nfs_release_automount_timer(void);
>>
>> +void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t  
>> *);
>> +
>
> Perhaps a better place for this would be fs/nfs/internal.h.  This  
> function is used only internally in fs/nfs; no need to expose it to user 
> space.

Yep, done.

--b.
