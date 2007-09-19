From: Chuck Lever <chuck.lever@oracle.com>
Subject: nfs_refresh_verifier / nfs_renew_times confusion
Date: Wed, 19 Sep 2007 16:20:56 -0400
Message-ID: <46F184A8.9050801@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080604030000080200040603"
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY64V-0001qG-Sd
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:22:56 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IY64Z-0000OA-BX
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:23:00 -0700
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
--------------080604030000080200040603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Trond-

I'm reviewing 2.6.23-rc6 + NFS_ALL to prepare for porting my BKL 
elimination patch series.  I'm confused by a couple of things I found in 
fs/nfs/dir.c.

1.

static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
{
         unsigned long verf;

         if (IS_ROOT(dentry))
                 return 1;
         verf = dentry->d_time;
         if (nfs_caches_unstable(dir)
                         || verf != NFS_I(dir)->cache_change_attribute)
                 return 0;
         return 1;
}

Why use the extra variable "verf" here?

2.

Three functions are defined:

static inline void nfs_set_verifier(struct dentry * dentry, unsigned 
long verf)
{
         dentry->d_time = verf;
}

static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
{
         nfs_set_verifier(dentry, verf);
}

static inline void nfs_renew_times(struct dentry * dentry)
{
         dentry->d_time = jiffies;
}

but later in the code I see this sequence several times:

         nfs_renew_times(dentry);
         nfs_refresh_verifier(dentry, verifier);

as well as this sequence:

         nfs_renew_times(dentry);
         nfs_set_verifier(dentry, nfs_save_change_attribute(dir));

In both cases, the second call overwrites the dentry's d_time field 
which was set to "jiffies" in the first call.

--------------080604030000080200040603
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


--------------080604030000080200040603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------080604030000080200040603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080604030000080200040603--
