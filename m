From: "lioupayphone" <lioupayphone@gmail.com>
Subject: Re: Re: what's the real meaning of fsid?
Date: Fri, 19 Dec 2008 23:04:25 +0800
Message-ID: <200812192304154217953@gmail.com>
References: <200812171336070316863@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:27335 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbYLSPEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 10:04:34 -0500
Received: by ti-out-0910.google.com with SMTP id b6so679122tic.23
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2008 07:04:31 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, J. Bruce Fields.
you wrote at 03:04:02 on 2008-12-19 :
>"Re: what's the real meaning of fsid?"
>On Wed, Dec 17, 2008 at 01:36:12PM +0800, lioupayphone wrote:
>> Hello, everyone. 
>> 
>> fsid in /etc/exports was used for identifying a file system. if a file system which exported 2 directories, it seems that we should tag the two export entries with same fsid.
>> 
>> eg
>> on one machine (server   10.10.37.147,  Centos5.2 with linux2.6.18):
>> 
>> #mkfs.ext3 /dev/sdc; mount /dev/sdc /mnt/;mkdir -p /mnt/dir1 /mnt/dir2; touch /mnt/dir1/wall-e /mnt/dir2/eva;
>> #echo "/mnt/dir1 *(rw,async,root_squash,fsid=2)" > /etc/exports
>> #echo "/mnt/dir2 *(rw,async,root_squash,fsid=2)" >> /etc/exports
>
>That's an odd thing to do; could you explain what you're trying to
>accomplish?
>
>--b.
thank you very much for your attentions. :-)
the comments listed below is from "man 5 exports":
---------------------------------------------------------
fsid=num
    This option forces the filesystem identification portion of the file handle and file attributes used on the wire to be num instead of a number derived from the major and minor number of the block device on which the filesystem is mounted. Any 32 bit number can be used, but it must be unique amongst all the exported filesystems.

    This can be useful for NFS failover, to ensure that both servers of the failover pair use the same NFS file handles for the shared filesystem thus avoiding stale file handles after failover.

    Some Linux filesystems are not mounted on a block device; exporting these via NFS requires the use of the fsid option (although that may still not be enough).

    The value 0 has a special meaning when use with NFSv4. NFSv4 has a concept of a root of the overall exported filesystem. The export point exported with fsid=0 will be used as this root. 
---------------------------------------------------------
i think this comments shows us such an info : "fsid" corresponds to a permanent "Major + Minor", which are usually used for identifying a block-device. but once failover, the Major/Minor of the device may be changed. so "fsid" was put forward.

but according to the log from NFSD, "struct knfsd_fh.fh_fsid" is just the value of "fsid" defined in /etc/exports, not "fsid" + 4 byte/8byte inode number.    i think "fsid + 4/8 bytes inode number" is the right meaning.

:-) it is just my personal opinion. please point out what's wrong i am. thank you very much.



>
>> #service nfs start && exportfs -r
>> 
>> on another machine (client   10.10.37.154):
>> #mount  10.10.37.147:/mnt/dir1 /mnt/1/ && mount 10.10.37.147:/mnt/dir2 /mnt/2/
>> 
>> i am puzzled:   on the client (10.10.37.154), i found both "/mnt/1/" and "/mnt/2/" have the same child ---- "wall-e".
>> 
>> so i browsed the code of 2.6.18 and found: exp_export(), fs/nfsd/export.c . i have taged a comment on this code listed below. please give me some suggestions. thx.
>> 
>> /*
>>  * Export a file system.
>>  */
>> int
>> exp_export(struct nfsctl_export *nxp)
>> {
>> 	svc_client	*clp;
>> 	struct svc_export	*exp = NULL;
>> 	struct svc_export	new;
>> 	struct svc_expkey	*fsid_key = NULL;
>> 	struct nameidata nd;
>> 	int		err;
>> 
>> 	/* Consistency check */
>> 	err = -EINVAL;
>> 	if (!exp_verify_string(nxp->ex_path, NFS_MAXPATHLEN) ||
>> 	    !exp_verify_string(nxp->ex_client, NFSCLNT_IDMAX))
>> 		goto out;
>> 
>> 	dprintk("exp_export called for %s:%s (%x/%ld fl %x).\n",
>> 			nxp->ex_client, nxp->ex_path,
>> 			(unsigned)nxp->ex_dev, (long)nxp->ex_ino,
>> 			nxp->ex_flags);
>> 
>> 	/* Try to lock the export table for update */
>> 	exp_writelock();
>> 
>> 	/* Look up client info */
>> 	if (!(clp = auth_domain_find(nxp->ex_client)))
>> 		goto out_unlock;
>> 
>> 
>> 	/* Look up the dentry */
>> 	err = path_lookup(nxp->ex_path, 0, &nd);
>> 	if (err)
>> 		goto out_unlock;
>> 	err = -EINVAL;
>> 
>> 	exp = exp_get_by_name(clp, nd.mnt, nd.dentry, NULL);
>> 
>> 	/* must make sure there won't be an ex_fsid clash */
>> 	if ((nxp->ex_flags & NFSEXP_FSID) &&
>> 	    (fsid_key = exp_get_fsid_key(clp, nxp->ex_dev)) &&
>> 	    !IS_ERR(fsid_key) &&
>> 	    fsid_key->ek_mnt &&
>> 		/* 
>> 		 * --> HERE.  "nd.mnt of "/mnt/dir1" and "/mnt/dir2" are same, but nd.dentry not.
>> 		 * "(fsid_key->ek_mnt != nd.mnt || fsid_key->ek_dentry != nd.dentry)" will be 1 in such
>> 		 * a situation. but they are different exp-entries in "/var/lib/nfs/etab"
>> 		* it should be "(fsid_key->ek_dentry != nd.dentry || fsid_key->ek_mnt != nd.mnt)" ??
>> 		 */
>> 	    (fsid_key->ek_mnt != nd.mnt || fsid_key->ek_dentry != nd.dentry) )        
>> 		goto finish;
>> 
>> 	if (exp) {
>> 		/* just a flags/id/fsid update */
>> 
>> 		exp_fsid_unhash(exp);
>> 		exp->ex_flags    = nxp->ex_flags;
>> 		exp->ex_anon_uid = nxp->ex_anon_uid;
>> 		exp->ex_anon_gid = nxp->ex_anon_gid;
>> 		exp->ex_fsid     = nxp->ex_dev;
>> 
>> 		err = exp_fsid_hash(clp, exp);
>> 		goto finish;
>> 	}
>> 
>> 	err = check_export(nd.dentry->d_inode, nxp->ex_flags);
>> 	if (err) goto finish;
>> 
>> 	err = -ENOMEM;
>> 
>> 	dprintk("nfsd: creating export entry %p for client %p\n", exp, clp);
>> 
>> 	new.h.expiry_time = NEVER;
>> 	new.h.flags = 0;
>> 	new.ex_client = clp;
>> 	new.ex_mnt = nd.mnt;
>> 	new.ex_dentry = nd.dentry;
>> 	new.ex_flags = nxp->ex_flags;
>> 	new.ex_anon_uid = nxp->ex_anon_uid;
>> 	new.ex_anon_gid = nxp->ex_anon_gid;
>> 	new.ex_fsid = nxp->ex_dev;
>> 
>> 	exp = svc_export_lookup(&new);
>> 	if (exp)
>> 		exp = svc_export_update(&new, exp);
>> 
>> 	if (!exp)
>> 		goto finish;
>> 
>> 	if (exp_hash(clp, exp) ||
>> 	    exp_fsid_hash(clp, exp)) {
>> 		/* failed to create at least one index */
>> 		exp_do_unexport(exp);
>> 		cache_flush();
>> 		err = -ENOMEM;
>> 	}
>> 
>> finish:
>> 	if (exp)
>> 		exp_put(exp);
>> 	if (fsid_key && !IS_ERR(fsid_key))
>> 		cache_put(&fsid_key->h, &svc_expkey_cache);
>> 	if (clp)
>> 		auth_domain_put(clp);
>> 	path_release(&nd);
>> out_unlock:
>> 	exp_writeunlock();
>> out:
>> 	return err;
>> }
>> 	
>> 	
>>  				
>> Best Regards! 
>> lioupayphone
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Best Regards!
lioupayphone

