From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs_refresh_verifier / nfs_renew_times confusion
Date: Wed, 19 Sep 2007 16:48:18 -0400
Message-ID: <46F18B12.4000802@oracle.com>
References: <46F184A8.9050801@oracle.com>
	<1190234217.6734.57.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090507020006060009000703"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY6UZ-0004h0-8b
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:49:51 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IY6Uc-0003Ck-T0
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:49:56 -0700
In-Reply-To: <1190234217.6734.57.camel@heimdal.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------090507020006060009000703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> Time to clean all that up. The legacy nfs_renew_times() has no meaning
> now that we use d_time to cache the verifier. Would you like to send me
> a patch removing them?

I can -- there are some minor nits.

In nfs_dentry_iput() we have this:

static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
{
         nfs_inode_return_delegation(inode);
         if (S_ISDIR(inode->i_mode))
                 /* drop any readdir cache as it could easily be old */
                 NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;

         if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
                 lock_kernel();
                 drop_nlink(inode);
                 nfs_complete_unlink(dentry, inode);
                 unlock_kernel();
         }
         /* When creating a negative dentry, we want to renew d_time */
         nfs_renew_times(dentry);
         ^^^^^^^^^^^^^^^^^^^^^^^^
         iput(inode);
}

This is the only instance of nfs_renew_times() by itself.  Seems like 
this might break the behavior of negative dentry caching.  Should this 
be removed entirely, or replaced somehow with nfs_refresh_verifier()?

It looks like nfs_set_verifier() and nfs_refresh_verifier() reduce to 
exactly the same logic, but we have this at the end of nfs_readdir_lookup:

         nfs_renew_times(dentry);
         nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
         return dentry;
out_renew:
         nfs_renew_times(dentry);
         nfs_refresh_verifier(dentry, nfs_save_change_attribute(dir));
         return dentry;
}

Both of which are exactly equivalent now.  I can address this as well.

--------------090507020006060009000703
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------090507020006060009000703
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------090507020006060009000703
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090507020006060009000703--
