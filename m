From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Sat, 17 Nov 2007 22:12:58 +0200
Message-ID: <600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: multipart/mixed; boundary="===============0815706249=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItU1h-0006KK-Mt
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:12:26 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItU1n-0005Xm-1Q
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:12:31 -0800
In-Reply-To: <1195328785.6999.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============0815706249==
Content-Type: multipart/signed; protocol="application/pgp-signature";
	micalg=pgp-sha1; boundary="Apple-Mail-23-127330064"
Content-Transfer-Encoding: 7bit

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-23-127330064
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

On 17.11.2007, at 21.46, Trond Myklebust wrote:

> On Sat, 2007-11-17 at 02:11 +0200, Timo Sirainen wrote:
>> Solaris and BSDs support flushing attribute cache safely using
>> fchown(fd, (uid_t)-1, (gid_t)-1). Could Linux be changed to  
>> support this
>> as well? If I'm looking at the sources right, this might work
>> (completely untested):
>>
>> --- inode.c.old 2007-11-16 22:18:46.000000000 +0200
>> +++ inode.c     2007-11-16 22:19:44.000000000 +0200
>> @@ -322,6 +322,7 @@
>>  nfs_setattr(struct dentry *dentry, struct iattr *attr)
>>  {
>>         struct inode *inode = dentry->d_inode;
>> +       struct nfs_inode *nfsi = NFS_I(inode);
>>         struct nfs_fattr fattr;
>>         int error;
>>
>> @@ -334,8 +335,10 @@
>>
>>         /* Optimization: if the end result is no change, don't RPC */
>>         attr->ia_valid &= NFS_VALID_ATTRS;
>> -       if (attr->ia_valid == 0)
>> +       if (attr->ia_valid == 0) {
>> +               nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
>>                 return 0;
>> +       }
>>
>>         lock_kernel();
>>         nfs_begin_data_update(inode);
>
> Why is this needed?

Do you mean why is flushing attribute cache needed, or why is this  
particular way to flush it needed?

I need to be able to find out if a file has changed, so I need to get  
its attribute cache flushed. fchown()ing to -1, -1 would work safely  
in all situations because it's guaranteed not to change the file in  
any way.

>> Another problem I have is that it's difficult to get a file's data  
>> cache
>> flushed. The only way I found was to successfully fcntl() lock the  
>> file.
>> This is pretty bad from performance point of view since often I don't
>> want/need to lock the file.
>>
>> Solaris and BSDs invalidate also a file's data cache when its  
>> attribute
>> cache is invalidated. It would be nicer if there was a separate  
>> way, but
>> I'd settle for fchown(fd, (uid_t)-1, (gid_t)-1) invalidating data  
>> cache
>> as well.
>>
>> Actually I did also look at posix_fadvise(fd, 0, 0,
>> POSIX_FADVN_DONTNEED). It appears to work, but I'm a bit worried  
>> about
>> race conditions that causes pages to randomly not get dropped because
>> invalidate_mapping_pages() doesn't drop locked pages.
>
> Again, why do you need this level of data cache invalidation? If you
> don't want cached i/o, then use O_DIRECT.

Because O_DIRECT is optional and I can't trust that support for it  
has been compiled into kernel. It defaults to off, and even its  
description makes it sound like it's a bad idea to enable normally.

Also O_DIRECT is a bit too much for my use case. I do want the file  
to be cached for the most part, but there are times occationally when  
parts of it can be overwritten, and I need to make sure that in those  
situations the newest data is read.

If you want a wider description of what I'm trying to do: I'm  
developing Dovecot IMAP server. A lot of people store mails on NFS  
and want to have multiple IMAP servers be able to access the mails.  
Dovecot uses somewhat complex index files to speed up accessing the  
mailboxes, and it's mainly for these index files that I need this  
explicit control over caching. If two servers are accessing the same  
mailbox at the same time, the index files get easily corrupted if I  
can't control the caching.

--Apple-Mail-23-127330064
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (Darwin)

iD8DBQFHP0tOyUhSUUBViskRAibtAJ42puyvvHDyxz6ftvWiFSApI9knpACgjd++
EvR4kVUYlL7LuX0luoDgDwg=
=uteE
-----END PGP SIGNATURE-----

--Apple-Mail-23-127330064--


--===============0815706249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0815706249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============0815706249==--


