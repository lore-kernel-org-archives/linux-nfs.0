From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_refresh_verifier / nfs_renew_times confusion
Date: Wed, 19 Sep 2007 16:36:57 -0400
Message-ID: <1190234217.6734.57.camel@heimdal.trondhjem.org>
References: <46F184A8.9050801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY6ID-0003TS-OQ
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:37:05 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IY6II-0005VF-1C
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 13:37:10 -0700
In-Reply-To: <46F184A8.9050801@oracle.com>
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

On Wed, 2007-09-19 at 16:20 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> I'm reviewing 2.6.23-rc6 + NFS_ALL to prepare for porting my BKL 
> elimination patch series.  I'm confused by a couple of things I found in 
> fs/nfs/dir.c.
> 
> 1.
> 
> static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
> {
>          unsigned long verf;
> 
>          if (IS_ROOT(dentry))
>                  return 1;
>          verf = dentry->d_time;
>          if (nfs_caches_unstable(dir)
>                          || verf != NFS_I(dir)->cache_change_attribute)
>                  return 0;
>          return 1;
> }
> 
> Why use the extra variable "verf" here?

Historical reasons: we used to cache the verifier in the
dentry->d_fsdata, which is a (void *). The new sillyrename code OTOH,
needs d_fsdata in order to cache the asynchronous unlink data, so the
verifier was moved into d_time.

> 2.
> 
> Three functions are defined:
> 
> static inline void nfs_set_verifier(struct dentry * dentry, unsigned 
> long verf)
> {
>          dentry->d_time = verf;
> }
> 
> static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
> {
>          nfs_set_verifier(dentry, verf);
> }
> 
> static inline void nfs_renew_times(struct dentry * dentry)
> {
>          dentry->d_time = jiffies;
> }
> 
> but later in the code I see this sequence several times:
> 
>          nfs_renew_times(dentry);
>          nfs_refresh_verifier(dentry, verifier);
> 
> as well as this sequence:
> 
>          nfs_renew_times(dentry);
>          nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
> 
> In both cases, the second call overwrites the dentry's d_time field 
> which was set to "jiffies" in the first call.

Time to clean all that up. The legacy nfs_renew_times() has no meaning
now that we use d_time to cache the verifier. Would you like to send me
a patch removing them?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
