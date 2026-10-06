Received: from sonic314-26.consmr.mail.ne1.yahoo.com (sonic314-26.consmr.mail.ne1.yahoo.com [66.163.189.152])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2825F49DB8A
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 15:31:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.163.189.152
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300675; cv=none; b=ivM15/l1X7+4Vafx429Y3ZBG2/hsywKuK9NJeBDo5oIzDAzSyKzpxIgpIRirzyfJFvED10AkoD1ZzysslHpGImsgMGJRpqwJYjQ1yaAcUIsK232TxAbfxKjgvzg4mMdKoAIIwuZRfucwNpmtQ/y6aTP+nDeP/mXdOhN2sB1gCQ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300675; c=relaxed/simple;
	bh=gaWYpagKLpUXK4jtv88AbO28xgKHLD6lkSrcvSkVS68=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=r+IPz90wnBoOuKuvZumrJ5DyjEbgVV/0FphqGkmjNrqpwv0v9PWZz1gfN311WHZc1NcZV9gT2hwLUhrNqmry5zEUxyCBXry+X2qAJHdrb+Nawt0m2L2/YWBxHHawGz/eVlXEYGiJsvn7jdwunjBuDofAAnvYL7Htu+EJaEBBjQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com; spf=pass smtp.mailfrom=schaufler-ca.com; dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b=jgi8QeZY; arc=none smtp.client-ip=66.163.189.152
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="jgi8QeZY"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1791300665; bh=/9nHT2a2RqnxT0kIO83nU2t78wlsYPKff8cHq4DQXfo=; h=Date:Subject:To:Cc:References:From:In-Reply-To:From:Subject:Reply-To; b=jgi8QeZY6OVWgpROoPwxDzAAAoRQY4kf0hVV4Cc3ts6FAMN1tqJRU4fSp4uK3o+biQczG+DsoEbX0GDotT20PR1NdTDXbCVAXlwvGYz1VKgRKWPu+XW5kLkUxDuHzuIojfzhXLfNJX4NAZfqZQaecMDHekPFO4CkMTsKhUo+4yfr2PS3d1BBAj7/a03J8T3huYDDlPfXAO34Df4isF8WTMm7LcjkmGmZY93xhq0aXdLVTKPwagt2kR2ICzGVLM5NFjgQHj6G9rXABaaO+WR1/ZKXY2c4HyjKGrVCfHrBRB9eBr/Q7J+RORfsAJ4G93cX1BLku0vwv1tKMDLmF2Y+zg==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1791300665; bh=qdLRXQFtDdHrcXOkw/ESn0t15sehrw5PGKvUP8DMaE9=; h=X-Sonic-MF:Date:Subject:To:From:From:Subject; b=ajaH6SpOkIZxxRvWcbTj8YR/57D/5qNjbsBTN7ETjv0htOjFf00GrrXra6TU16j5vk1i1cYYQjQ7WvYaQqcgoJiJRUp0p2q9GwKstCrM5lVxUDkUjGUSD+W3Q/3+UVoULedRK+o2n6OYtjMXZzG+IPVO/gbP+k3MQ3OWaasYP5rHFO6blqXdh0/0H7jR1A2udrHGwjHNvc8ZYLdOA5baOwDMNC3iQuarKrPhC8XQiUQS6kqKBCO0Pyh0/WwxFVrAWTyYIGhtT/vEUvndnFcbnw41S8EG9lGjfedqg4xBDRcyk3aP52i9BF6Y+wdP17Ud0vj/3kM1vj0Pw0+0oi0TFQ==
X-YMail-OSG: A_mmuZgVM1kwy262Tnh3QxdTHrwNxMF.hNB6yk8sh6xFDFL.lSJ7iLe7QicwbIJ
 uaiFYMRkGK1I8XMeoF8pfh.pm5Q5OD1Yb3zEibptgzlTq5IKCsUBvcpF8QmS5tCpTpMXE6jlkdU4
 BrsoXAxZ3za2H7EvYrk2L7uwZ5dWfMaNRHsXRDJzk1H.ZFQjszqO5Jx.iepUX3I_Ouxs0T6cAG7Z
 9bY4yh4w5X2xsHlt8zOUD7StgFJa75s0f0pvFCm35Ck4cckUVLBatGQQYyGBjWgpE0XU7IyE2fiO
 EuGbPBW9MDKsIM4ABfsTEYYl1JB178mvWxOxvdReMztNajliXCmmUvv2nIo_NulI6Jn4x1tduaHK
 4caYLzFvasRYGRRP2ySJPQfPSPB6rJFip4MExsta2k7hgWTiBWwMiQ8mnWCmg5u.TAkYC83WVUV9
 FJxHeiT.OJqkGzebtwMCypMiVh6ZwWrBe4cIYaOpqHmCyrs7Bc42rwlD3JEH0OTq1mdfgCDWYQQ7
 amKrZ.HWoRC7skIZZngb0SPZ.50I32PJZN6gI7GYLOQeNK2l.UaA2nIEpAFDn0yn57fc22ZVaqO_
 3BCU2.xEOx0j9PqzaRw02v8fI0PL1Uo11xPqTFxWM9TuoAgz3pnauqsg7XQCYXvNvJntelK9Vq3j
 hu0Ds2UnuD80jpAevEWuBIKDwieDvgyoaZDXgRSVgj8kzR0GN8kCNhwsMzBqkBRw9.CITMpmNSLr
 NXpNpde7p9Mrg17PAwUl7Z.JH34CHsu8JwZTkruG3qCyvIroNcF_Ze_9wbTfK4uqMuCEF6eXh3ol
 BAy7zCm.ZlXtNFBPeRHZHn5rpCCByAqpfYDa.Qv.BPQLudRPJwzVc4uLlMwB3KhqTmEyiL9qwO3j
 tnW2NXsl27IHZNbx78MG7s2Ol08ek8SCINZG0zaPmkVB_SNwP79WzCRmD6WfF9FsJFPBQyYAFCGy
 qyhqw0Bw8D5MK0Zn8sOTMPEGVaoDbsP_gct0GWRaedTFfTdchEI_4oVT4rdbDZOvrVRXBk9xJfvO
 7NJx8SCiasn4N0jxtjbGgpaFW98w0xU6TGmkli0pSg9OYXAoXNn8KPYPyOoQDboEGoyxlv8hDoo4
 weAS9zvE5H45yhO7WfZI6ZtqpYsTjNPIog.4LlJPXsWjGunRNWReZ.71U19Pz.f8vTpb5kzyaDNl
 7foVXMCraTxFbaDOZHA5tSgQt3W7Tf2Im_ArtxbF9SNfvPjn8tVQgN_Zgp3xqRQGn4qEqqMyMXt3
 TpK4WM8tYj95iaT8kWS32jv6BQHiuTOfyxECXoOOgdHWqXScJ1UBXBoRg.2U4hUzpVvP0bcpdWNq
 idSewEnKyAoOFpGc_awIVYuFv1ZGlcIjZfJ6__VnTqQqphNNwJ9Ne40sl7d2EgQu2EunhMtUYlVy
 hpmmWdStEIpwKDmYRhFANbgTOFbDo022lPkNFU_KfszQVMp5UgyLijd3Ne0REqrkxLFMPGgTVRRT
 GUmkDxoPMNl.r7xXTuD1ImmIC8cZv8.pvtqGIADNIbV6n0AGgOf3vCmXCAHJscdP0IWQYwPG1pZ0
 cAVK_miyPgXEz80SOJaU63Wm0Bm9NlVv5PQk0LHXpiU.KzXHN_mSFEBnxbxfTOLobpmby7Wgzt1q
 PUZCa5Qu8rJURACh.Vy8T507irijsj9F.JbyVrpZw5wJmL7m1IcKatqfrk01vp5.VNM9oDIin9SH
 .4w8H5KsplMFm5yJQm21Y1iBmBpfPL2p76PkjxK2lkCmjIWCN5ZYx5XzJC3qLgqvf7PksnB_Gy.V
 fNOwPHb0YCfeuH3q5HuTB6ufo8AZW3TJCiY.cgGnCV.yZMjj.5ZfC3o4kO5.rB3CyicVAJsJIg5f
 I7YmhQkH2XXz3U.5L1Wh7coGGLvUWmLU4JQEE8oYw2tqdAcf7njSn7g1a3a6kI2jYb5Gukrt21LO
 _CVCyl6rrx_XwzL7cb.uUFJvFUF7zyfHAePne6e15xynYfBgZZLO2f8pku7zhqBN_jnXWGr4NLmc
 fZdjM3CQwEOu59XpISgfsAwSl5fr3mOIX3OqiGo25iHjWcX3zNU7QX48voPbj_MwRRFgijYGMwfE
 4tDyBKpoXJBONwYBkK62jQxKtCNZz6q137lJv4seCU8s7Hj.qRWQfxKnLX8Bi6LrHobkAA90DK38
 wooUMzURnrtP8kAxtmdo.4KSHvieXOhswdL3okEHtKjF5VIwOh37mP0kl4L36VQgvNhx4yJU.1wI
 EwIDQFeiLmYofz820uiaalsg3ZAGakwUNKdOryIHjbQQWYFC3I2w65tbgGwbW3D9EUxd9VMliyu5
 ssokS
X-Sonic-MF: <casey@schaufler-ca.com>
X-Sonic-ID: 42718f3c-43a2-42f3-b8e7-7ee7e31a7fbd
Received: from sonic.gate.mail.ne1.yahoo.com by sonic314.consmr.mail.ne1.yahoo.com with HTTP; Tue, 6 Oct 2026 15:31:05 +0000
Received: by hermes--production-gq1-fd7994565-ntx8j (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID d6c3c8f00cda88ff095d27bfdb463956;
          Tue, 06 Oct 2026 15:31:03 +0000 (UTC)
Message-ID: <b7cb5ad4-666c-4cd2-bb18-8f159223c478@schaufler-ca.com>
Date: Tue, 6 Oct 2026 08:31:00 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC -next 03/12] fs: pass struct path to xattr helpers
To: Cai Xinchen <caixinchen1@huawei.com>, mic@digikod.net, gnoack@google.com,
 paul@paul-moore.com, jmorris@namei.org, serge@hallyn.com, corbet@lwn.net,
 skhan@linuxfoundation.org
Cc: rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org,
 dakr@kernel.org, dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk,
 viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz,
 dhowells@redhat.com, code@tyhicks.com, linkinjeon@kernel.org,
 sj1557.seo@samsung.com, yuezhang.mo@sony.com, hirofumi@mail.parknet.co.jp,
 cel@kernel.org, jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, miklos@szeredi.hu, amir73il@gmail.com,
 senozhatsky@chromium.org, chenxiaosong@chenxiaosong.com,
 zohar@linux.ibm.com, roberto.sassu@huawei.com, dmitry.kasatkin@gmail.com,
 eric.snowberg@oracle.com, stephen.smalley.work@gmail.com,
 omosnacek@gmail.com, nanx95726@gmail.com, djwong@kernel.org,
 daniel@iogearbox.net, linux-security-module@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
 driver-core@lists.linux.dev, linux-block@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, netfs@lists.linux.dev,
 ecryptfs@vger.kernel.org, exfat@lists.linux.dev, linux-nfs@vger.kernel.org,
 linux-unionfs@vger.kernel.org, linux-cifs@vger.kernel.org,
 linux-integrity@vger.kernel.org, selinux@vger.kernel.org,
 linux-kselftest@vger.kernel.org, xiujianfeng@huawei.com,
 lujialin4@huawei.com, Casey Schaufler <casey@schaufler-ca.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260924104831.1081137-4-caixinchen1@huawei.com>
Content-Language: en-US
From: Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <20260924104831.1081137-4-caixinchen1@huawei.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Mailer: WebService/1.1.26668 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

On 9/24/2026 3:48 AM, Cai Xinchen wrote:
> vfs_setxattr(), vfs_getxattr(), vfs_listxattr() and vfs_removexattr()
> along with their __vfs_setxattr_locked()/__vfs_removexattr_locked()
> counterparts and the do_setxattr()/do_getxattr()/listxattr()/
> removexattr() syscall helpers take a struct mnt_idmap and a struct
> dentry even though callers either already hold a struct path (or a
> struct file) or have to pass &nop_mnt_idmap because no idmapped
> mount is involved.  Switch them all to take a struct path instead
> and derive the idmap and dentry from it where needed.
>
> __vfs_setxattr_noperm(), __vfs_getxattr(), __vfs_setxattr(),
> __vfs_removexattr() and vfs_getxattr_alloc() keep taking the idmap
> and dentry as they are only called from contexts that operate on
> bare dentries such as LSM internals.  The SELinux and Smack
> inode_setsecctx implementations now pass the path they got from the
> previous patch straight through.
>
> The security_inode_*xattr() hooks invoked from fs/xattr.c keep
> taking the idmap and dentry for now; they will be converted together
> with the LSM hooks themselves in separate patches.
>
> evm_calc_hmac_or_hash() contains a redundant xattr size sanity check
> which calls vfs_getxattr() only to emit a debug message when the
> kernel-side and user-space-side xattr sizes differ, without ever
> influencing the result.  Because that function only has a dentry, the
> call cannot be migrated to the new path-based signature; drop the
> check and the now unused user_space_size variable instead.
>
> Assisted-by: opencode: glm-5.3
> Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>

The Smack changes appear sane.
Acked-by: Casey Schaufler <casey@schaufler-ca.com>

> ---
>  drivers/block/zloop.c               |   4 +-
>  fs/cachefiles/xattr.c               |  32 ++++----
>  fs/ecryptfs/inode.c                 |   8 +-
>  fs/nfsd/nfs4ctl.h                   |   4 +-
>  fs/nfsd/vfs.c                       |  57 +++++++-------
>  fs/overlayfs/copy_up.c              |   4 +-
>  fs/overlayfs/overlayfs.h            |  18 +++--
>  fs/overlayfs/xattrs.c               |  13 +++-
>  fs/smb/server/smb2pdu.c             |  75 +++++++------------
>  fs/smb/server/smb_common.c          |   2 -
>  fs/smb/server/smbacl.c              |  19 +++--
>  fs/smb/server/tests/smbacl_kunit.c  |   6 +-
>  fs/smb/server/vfs.c                 | 112 ++++++++++++----------------
>  fs/smb/server/vfs.h                 |  39 ++++------
>  fs/smb/server/vfs_cache.c           |   3 +-
>  fs/xattr.c                          |  92 ++++++++++++-----------
>  include/linux/xattr.h               |  22 +++---
>  security/integrity/evm/evm_crypto.c |   8 +-
>  security/selinux/hooks.c            |   4 +-
>  security/smack/smack_lsm.c          |   4 +-
>  20 files changed, 243 insertions(+), 283 deletions(-)
>
> diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
> index f0ca221524db..d77b114d69fc 100644
> --- a/drivers/block/zloop.c
> +++ b/drivers/block/zloop.c
> @@ -710,7 +710,7 @@ static int zloop_record_safe_wps(struct zloop_device *zlo)
>  
>  		if (!zloop_zone_is_active(zone))
>  			continue;
> -		ret = vfs_setxattr(file_mnt_idmap(file), file_dentry(file),
> +		ret = vfs_setxattr(&file->f_path,
>  				"user.zloop.wp", &zone->wp, sizeof(zone->wp), 0);
>  		if (ret) {
>  			pr_err("%pg: failed to record write pointer (%d)\n",
> @@ -1395,7 +1395,7 @@ static void zloop_forget_cache(struct zloop_device *zlo)
>  		if (!zloop_zone_is_active(zone))
>  			continue;
>  
> -		ret = vfs_getxattr(file_mnt_idmap(file), file_dentry(file),
> +		ret = vfs_getxattr(&file->f_path,
>  				"user.zloop.wp", &old_wp, sizeof(old_wp));
>  		if (ret == -ENODATA) {
>  			old_wp = 0;
> diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
> index c70bf67e52b0..5a0b50bcfb73 100644
> --- a/fs/cachefiles/xattr.c
> +++ b/fs/cachefiles/xattr.c
> @@ -40,14 +40,12 @@ struct cachefiles_vol_xattr {
>  int cachefiles_set_object_xattr(struct cachefiles_object *object)
>  {
>  	struct cachefiles_xattr *buf;
> -	struct dentry *dentry;
>  	struct file *file = object->file;
>  	unsigned int len = object->cookie->aux_len;
>  	int ret;
>  
>  	if (!file)
>  		return -ESTALE;
> -	dentry = file->f_path.dentry;
>  
>  	_enter("%x,#%d", object->debug_id, len);
>  
> @@ -69,7 +67,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
>  	if (ret == 0) {
>  		ret = mnt_want_write_file(file);
>  		if (ret == 0) {
> -			ret = vfs_setxattr(&nop_mnt_idmap, dentry,
> +			ret = vfs_setxattr(&file->f_path,
>  					   cachefiles_xattr_cache, buf,
>  					   sizeof(struct cachefiles_xattr) + len, 0);
>  			mnt_drop_write_file(file);
> @@ -102,7 +100,6 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
>  int cachefiles_check_auxdata(struct cachefiles_object *object, struct file *file)
>  {
>  	struct cachefiles_xattr *buf;
> -	struct dentry *dentry = file->f_path.dentry;
>  	unsigned int len = object->cookie->aux_len, tlen;
>  	const void *p = fscache_get_aux(object->cookie);
>  	enum cachefiles_coherency_trace why;
> @@ -117,7 +114,7 @@ int cachefiles_check_auxdata(struct cachefiles_object *object, struct file *file
>  
>  	xlen = cachefiles_inject_read_error();
>  	if (xlen == 0)
> -		xlen = vfs_getxattr(&nop_mnt_idmap, dentry, cachefiles_xattr_cache, buf, tlen);
> +		xlen = vfs_getxattr(&file->f_path, cachefiles_xattr_cache, buf, tlen);
>  	if (xlen != tlen) {
>  		if (xlen < 0) {
>  			ret = xlen;
> @@ -161,14 +158,14 @@ int cachefiles_remove_object_xattr(struct cachefiles_cache *cache,
>  				   struct cachefiles_object *object,
>  				   struct dentry *dentry)
>  {
> +	struct path path = { .mnt = cache->mnt, .dentry = dentry };
>  	int ret;
>  
>  	ret = cachefiles_inject_remove_error();
>  	if (ret == 0) {
>  		ret = mnt_want_write(cache->mnt);
>  		if (ret == 0) {
> -			ret = vfs_removexattr(&nop_mnt_idmap, dentry,
> -					      cachefiles_xattr_cache);
> +			ret = vfs_removexattr(&path, cachefiles_xattr_cache);
>  			mnt_drop_write(cache->mnt);
>  		}
>  	}
> @@ -214,7 +211,8 @@ bool cachefiles_set_volume_xattr(struct cachefiles_volume *volume)
>  	struct cachefiles_vol_xattr *buf;
>  	unsigned int len = volume->vcookie->coherency_len;
>  	const void *p = volume->vcookie->coherency;
> -	struct dentry *dentry = volume->dentry;
> +	struct path path = { .mnt = volume->cache->mnt,
> +			     .dentry = volume->dentry };
>  	int ret;
>  
>  	_enter("%x,#%d", volume->vcookie->debug_id, len);
> @@ -230,22 +228,21 @@ bool cachefiles_set_volume_xattr(struct cachefiles_volume *volume)
>  	if (ret == 0) {
>  		ret = mnt_want_write(volume->cache->mnt);
>  		if (ret == 0) {
> -			ret = vfs_setxattr(&nop_mnt_idmap, dentry,
> -					   cachefiles_xattr_cache,
> +			ret = vfs_setxattr(&path, cachefiles_xattr_cache,
>  					   buf, len, 0);
>  			mnt_drop_write(volume->cache->mnt);
>  		}
>  	}
>  	if (ret < 0) {
> -		trace_cachefiles_vfs_error(NULL, d_inode(dentry), ret,
> +		trace_cachefiles_vfs_error(NULL, d_inode(path.dentry), ret,
>  					   cachefiles_trace_setxattr_error);
> -		trace_cachefiles_vol_coherency(volume, d_inode(dentry)->i_ino,
> +		trace_cachefiles_vol_coherency(volume, d_inode(path.dentry)->i_ino,
>  					       cachefiles_coherency_vol_set_fail);
>  		if (ret != -ENOMEM)
>  			cachefiles_io_error(
>  				volume->cache, "Failed to set xattr with error %d", ret);
>  	} else {
> -		trace_cachefiles_vol_coherency(volume, d_inode(dentry)->i_ino,
> +		trace_cachefiles_vol_coherency(volume, d_inode(path.dentry)->i_ino,
>  					       cachefiles_coherency_vol_set_ok);
>  	}
>  
> @@ -260,9 +257,10 @@ bool cachefiles_set_volume_xattr(struct cachefiles_volume *volume)
>  int cachefiles_check_volume_xattr(struct cachefiles_volume *volume)
>  {
>  	struct cachefiles_vol_xattr *buf;
> -	struct dentry *dentry = volume->dentry;
>  	unsigned int len = volume->vcookie->coherency_len;
>  	const void *p = volume->vcookie->coherency;
> +	struct path path = { .mnt = volume->cache->mnt,
> +			     .dentry = volume->dentry };
>  	enum cachefiles_coherency_trace why;
>  	ssize_t xlen;
>  	int ret = -ESTALE;
> @@ -276,11 +274,11 @@ int cachefiles_check_volume_xattr(struct cachefiles_volume *volume)
>  
>  	xlen = cachefiles_inject_read_error();
>  	if (xlen == 0)
> -		xlen = vfs_getxattr(&nop_mnt_idmap, dentry, cachefiles_xattr_cache, buf, len);
> +		xlen = vfs_getxattr(&path, cachefiles_xattr_cache, buf, len);
>  	if (xlen != len) {
>  		if (xlen < 0) {
>  			ret = xlen;
> -			trace_cachefiles_vfs_error(NULL, d_inode(dentry), xlen,
> +			trace_cachefiles_vfs_error(NULL, d_inode(path.dentry), xlen,
>  						   cachefiles_trace_getxattr_error);
>  			if (xlen == -EIO)
>  				cachefiles_io_error(
> @@ -297,7 +295,7 @@ int cachefiles_check_volume_xattr(struct cachefiles_volume *volume)
>  		ret = 0;
>  	}
>  
> -	trace_cachefiles_vol_coherency(volume, d_inode(dentry)->i_ino, why);
> +	trace_cachefiles_vol_coherency(volume, d_inode(path.dentry)->i_ino, why);
>  	kfree(buf);
>  	_leave(" = %d", ret);
>  	return ret;
> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> index 627d456f9c38..3307cf13b5b4 100644
> --- a/fs/ecryptfs/inode.c
> +++ b/fs/ecryptfs/inode.c
> @@ -991,17 +991,17 @@ ecryptfs_setxattr(struct dentry *dentry, struct inode *inode,
>  		  size_t size, int flags)
>  {
>  	int rc;
> -	struct dentry *lower_dentry;
> +	struct path lower_path;
>  	struct inode *lower_inode;
>  
> -	lower_dentry = ecryptfs_dentry_to_lower(dentry);
> -	lower_inode = d_inode(lower_dentry);
> +	lower_path = ecryptfs_lower_path(dentry);
> +	lower_inode = d_inode(lower_path.dentry);
>  	if (!(lower_inode->i_opflags & IOP_XATTR)) {
>  		rc = -EOPNOTSUPP;
>  		goto out;
>  	}
>  	inode_lock(lower_inode);
> -	rc = __vfs_setxattr_locked(&nop_mnt_idmap, lower_dentry, name, value, size, flags, NULL);
> +	rc = __vfs_setxattr_locked(&lower_path, name, value, size, flags, NULL);
>  	inode_unlock(lower_inode);
>  	if (!rc && inode)
>  		fsstack_copy_attr_all(inode, lower_inode);
> diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
> index bcec4c4ef1d5..97ab3d4212aa 100644
> --- a/fs/nfsd/nfs4ctl.h
> +++ b/fs/nfsd/nfs4ctl.h
> @@ -38,7 +38,7 @@ int nfsd4_create_laundry_wq(void);
>  void nfsd4_destroy_laundry_wq(void);
>  bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
>  
> -extern int nfsd4_is_junction(struct dentry *dentry);
> +extern int nfsd4_is_junction(const struct path *path);
>  extern int register_cld_notifier(void);
>  extern void unregister_cld_notifier(void);
>  #ifdef CONFIG_NFSD_V4_2_INTER_SSC
> @@ -68,7 +68,7 @@ static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
>  	return false;
>  }
>  
> -static inline int nfsd4_is_junction(struct dentry *dentry)
> +static inline int nfsd4_is_junction(const struct path *path)
>  {
>  	return 0;
>  }
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 922337083fe9..a3b86fa60dca 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -233,11 +233,13 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
>   */
>  int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
>  {
> +	struct path path = { .mnt = exp->ex_path.mnt, .dentry = dentry };
> +
>  	if (!d_inode(dentry))
>  		return 0;
>  	if (exp->ex_flags & NFSEXP_V4ROOT)
>  		return 1;
> -	if (nfsd4_is_junction(dentry))
> +	if (nfsd4_is_junction(&path))
>  		return 1;
>  	if (d_managed(dentry))
>  		/*
> @@ -684,14 +686,14 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  /**
>   * nfsd4_is_junction - Test if an object could be an NFS junction
>   *
> - * @dentry: object to test
> + * @path: object to test
>   *
> - * Returns 1 if "dentry" appears to contain NFS junction information.
> + * Returns 1 if "path" appears to contain NFS junction information.
>   * Otherwise 0 is returned.
>   */
> -int nfsd4_is_junction(struct dentry *dentry)
> +int nfsd4_is_junction(const struct path *path)
>  {
> -	struct inode *inode = d_inode(dentry);
> +	struct inode *inode = d_inode(path->dentry);
>  
>  	if (inode == NULL)
>  		return 0;
> @@ -699,8 +701,7 @@ int nfsd4_is_junction(struct dentry *dentry)
>  		return 0;
>  	if (!(inode->i_mode & S_ISVTX))
>  		return 0;
> -	if (vfs_getxattr(&nop_mnt_idmap, dentry, NFSD_JUNCTION_XATTR_NAME,
> -			 NULL, 0) <= 0)
> +	if (vfs_getxattr(path, NFSD_JUNCTION_XATTR_NAME, NULL, 0) <= 0)
>  		return 0;
>  	return 1;
>  }
> @@ -2619,19 +2620,20 @@ nfsd_getxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name,
>  	__be32 err;
>  	char *buf;
>  	struct inode *inode;
> -	struct dentry *dentry;
> +	struct path path;
>  
>  	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_READ);
>  	if (err)
>  		return err;
>  
>  	err = nfs_ok;
> -	dentry = fhp->fh_dentry;
> -	inode = d_inode(dentry);
> +	path.mnt = fhp->fh_export->ex_path.mnt;
> +	path.dentry = fhp->fh_dentry;
> +	inode = d_inode(path.dentry);
>  
>  	inode_lock_shared(inode);
>  
> -	len = vfs_getxattr(&nop_mnt_idmap, dentry, name, NULL, 0);
> +	len = vfs_getxattr(&path, name, NULL, 0);
>  
>  	/*
>  	 * Zero-length attribute, just return.
> @@ -2658,7 +2660,7 @@ nfsd_getxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name,
>  		goto out;
>  	}
>  
> -	len = vfs_getxattr(&nop_mnt_idmap, dentry, name, buf, len);
> +	len = vfs_getxattr(&path, name, buf, len);
>  	if (len <= 0) {
>  		kvfree(buf);
>  		buf = NULL;
> @@ -2692,19 +2694,20 @@ nfsd_listxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char **bufp,
>  	__be32 err;
>  	char *buf;
>  	struct inode *inode;
> -	struct dentry *dentry;
> +	struct path path;
>  
>  	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_READ);
>  	if (err)
>  		return err;
>  
> -	dentry = fhp->fh_dentry;
> -	inode = d_inode(dentry);
> +	path.mnt = fhp->fh_export->ex_path.mnt;
> +	path.dentry = fhp->fh_dentry;
> +	inode = d_inode(path.dentry);
>  	*lenp = 0;
>  
>  	inode_lock_shared(inode);
>  
> -	len = vfs_listxattr(dentry, NULL, 0);
> +	len = vfs_listxattr(&path, NULL, 0);
>  	if (len <= 0) {
>  		err = nfsd_xattr_errno(len);
>  		goto out;
> @@ -2721,7 +2724,7 @@ nfsd_listxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char **bufp,
>  		goto out;
>  	}
>  
> -	len = vfs_listxattr(dentry, buf, len);
> +	len = vfs_listxattr(&path, buf, len);
>  	if (len <= 0) {
>  		kvfree(buf);
>  		err = nfsd_xattr_errno(len);
> @@ -2754,6 +2757,7 @@ nfsd_removexattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name)
>  {
>  	__be32 err;
>  	int ret;
> +	struct path path;
>  
>  	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_WRITE);
>  	if (err)
> @@ -2763,16 +2767,17 @@ nfsd_removexattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name)
>  	if (ret)
>  		return nfserrno(ret);
>  
> -	inode_lock(fhp->fh_dentry->d_inode);
> +	path.mnt = fhp->fh_export->ex_path.mnt;
> +	path.dentry = fhp->fh_dentry;
> +	inode_lock(d_inode(path.dentry));
>  	err = fh_fill_pre_attrs(fhp);
>  	if (err != nfs_ok)
>  		goto out_unlock;
> -	ret = __vfs_removexattr_locked(&nop_mnt_idmap, fhp->fh_dentry,
> -				       name, NULL);
> +	ret = __vfs_removexattr_locked(&path, name, NULL);
>  	err = nfsd_xattr_errno(ret);
>  	fh_fill_post_attrs(fhp);
>  out_unlock:
> -	inode_unlock(fhp->fh_dentry->d_inode);
> +	inode_unlock(d_inode(path.dentry));
>  	fh_drop_write(fhp);
>  
>  	return err;
> @@ -2784,6 +2789,7 @@ nfsd_setxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name,
>  {
>  	__be32 err;
>  	int ret;
> +	struct path path;
>  
>  	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_WRITE);
>  	if (err)
> @@ -2792,16 +2798,17 @@ nfsd_setxattr(struct svc_rqst *rqstp, struct svc_fh *fhp, char *name,
>  	ret = fh_want_write(fhp);
>  	if (ret)
>  		return nfserrno(ret);
> -	inode_lock(fhp->fh_dentry->d_inode);
> +	path.mnt = fhp->fh_export->ex_path.mnt;
> +	path.dentry = fhp->fh_dentry;
> +	inode_lock(d_inode(path.dentry));
>  	err = fh_fill_pre_attrs(fhp);
>  	if (err != nfs_ok)
>  		goto out_unlock;
> -	ret = __vfs_setxattr_locked(&nop_mnt_idmap, fhp->fh_dentry,
> -				    name, buf, len, flags, NULL);
> +	ret = __vfs_setxattr_locked(&path, name, buf, len, flags, NULL);
>  	fh_fill_post_attrs(fhp);
>  	err = nfsd_xattr_errno(ret);
>  out_unlock:
> -	inode_unlock(fhp->fh_dentry->d_inode);
> +	inode_unlock(d_inode(path.dentry));
>  	fh_drop_write(fhp);
>  	return err;
>  }
> diff --git a/fs/overlayfs/copy_up.c b/fs/overlayfs/copy_up.c
> index e963701b4c87..6dc241f195a6 100644
> --- a/fs/overlayfs/copy_up.c
> +++ b/fs/overlayfs/copy_up.c
> @@ -83,7 +83,7 @@ int ovl_copy_xattr(struct super_block *sb, const struct path *oldpath, struct de
>  	if (!old->d_inode->i_op->listxattr || !new->d_inode->i_op->listxattr)
>  		return 0;
>  
> -	list_size = vfs_listxattr(old, NULL, 0);
> +	list_size = vfs_listxattr(oldpath, NULL, 0);
>  	if (list_size <= 0) {
>  		if (list_size == -EOPNOTSUPP)
>  			return 0;
> @@ -94,7 +94,7 @@ int ovl_copy_xattr(struct super_block *sb, const struct path *oldpath, struct de
>  	if (!buf)
>  		return -ENOMEM;
>  
> -	list_size = vfs_listxattr(old, buf, list_size);
> +	list_size = vfs_listxattr(oldpath, buf, list_size);
>  	if (list_size <= 0) {
>  		error = list_size;
>  		goto out;
> diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
> index d915b87c0b06..c13f6b2c915c 100644
> --- a/fs/overlayfs/overlayfs.h
> +++ b/fs/overlayfs/overlayfs.h
> @@ -291,8 +291,7 @@ static inline ssize_t ovl_do_getxattr(const struct path *path, const char *name,
>  
>  	WARN_ON(path->dentry->d_sb != path->mnt->mnt_sb);
>  
> -	err = vfs_getxattr(mnt_idmap(path->mnt), path->dentry,
> -			       name, value, size);
> +	err = vfs_getxattr(path, name, value, size);
>  	len = (value && err > 0) ? err : 0;
>  
>  	pr_debug("getxattr(%pd2, \"%s\", \"%*pE\", %zu, 0) = %i\n",
> @@ -325,9 +324,13 @@ static inline int ovl_do_setxattr(struct ovl_fs *ofs, struct dentry *dentry,
>  				  const char *name, const void *value,
>  				  size_t size, int flags)
>  {
> +	struct path path = {
> +		.mnt = ovl_upper_mnt(ofs),
> +		.dentry = dentry,
> +	};
> +
>  	/* Use vfs_setxattr(), not __vfs_setxattr(): it idmaps the security.capability rootid. */
> -	int err = vfs_setxattr(ovl_upper_mnt_idmap(ofs), dentry, name,
> -			       value, size, flags);
> +	int err = vfs_setxattr(&path, name, value, size, flags);
>  
>  	pr_debug("setxattr(%pd2, \"%s\", \"%*pE\", %zu, %d) = %i\n",
>  		 dentry, name, min((int)size, 48), value, size, flags, err);
> @@ -344,7 +347,12 @@ static inline int ovl_setxattr(struct ovl_fs *ofs, struct dentry *dentry,
>  static inline int ovl_do_removexattr(struct ovl_fs *ofs, struct dentry *dentry,
>  				     const char *name)
>  {
> -	int err = vfs_removexattr(ovl_upper_mnt_idmap(ofs), dentry, name);
> +	struct path path = {
> +		.mnt = ovl_upper_mnt(ofs),
> +		.dentry = dentry,
> +	};
> +
> +	int err = vfs_removexattr(&path, name);
>  	pr_debug("removexattr(%pd2, \"%s\") = %i\n", dentry, name, err);
>  	return err;
>  }
> diff --git a/fs/overlayfs/xattrs.c b/fs/overlayfs/xattrs.c
> index 5ae44b9c8790..b4658324b9f3 100644
> --- a/fs/overlayfs/xattrs.c
> +++ b/fs/overlayfs/xattrs.c
> @@ -45,7 +45,7 @@ static int ovl_xattr_set(struct dentry *dentry, struct inode *inode, const char
>  	if (!value && !upperdentry) {
>  		ovl_path_lower(dentry, &realpath);
>  		with_ovl_creds(dentry->d_sb)
> -			err = vfs_getxattr(mnt_idmap(realpath.mnt), realdentry, name, NULL, 0);
> +			err = vfs_getxattr(&realpath, name, NULL, 0);
>  		if (err < 0)
>  			goto out;
>  	}
> @@ -86,7 +86,7 @@ static int ovl_xattr_get(struct dentry *dentry, struct inode *inode, const char
>  	ovl_i_path_real(inode, &realpath);
>  	/* Use vfs_getxattr(), not __vfs_getxattr(): it idmaps the security.capability rootid. */
>  	with_ovl_creds(dentry->d_sb)
> -		return vfs_getxattr(mnt_idmap(realpath.mnt), realpath.dentry, name, value, size);
> +		return vfs_getxattr(&realpath, name, value, size);
>  }
>  
>  static bool ovl_can_list(struct super_block *sb, const char *s)
> @@ -105,15 +105,20 @@ static bool ovl_can_list(struct super_block *sb, const char *s)
>  
>  ssize_t ovl_listxattr(struct dentry *dentry, char *list, size_t size)
>  {
> -	struct dentry *realdentry = ovl_dentry_real(dentry);
> +	struct path realpath;
>  	struct ovl_fs *ofs = OVL_FS(dentry->d_sb);
>  	ssize_t res;
>  	size_t len;
>  	char *s;
>  	size_t prefix_len, name_len;
>  
> +	if (ovl_dentry_upper(dentry))
> +		ovl_path_upper(dentry, &realpath);
> +	else
> +		ovl_path_lower(dentry, &realpath);
> +
>  	with_ovl_creds(dentry->d_sb)
> -		res = vfs_listxattr(realdentry, list, size);
> +		res = vfs_listxattr(&realpath, list, size);
>  	if (res <= 0 || size == 0)
>  		return res;
>  
> diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
> index fb3ee170db3c..b5db5f280701 100644
> --- a/fs/smb/server/smb2pdu.c
> +++ b/fs/smb/server/smb2pdu.c
> @@ -3293,7 +3293,6 @@ static bool smb2_is_private_ea(const char *name, size_t name_len)
>  static int smb2_set_ea(struct smb2_ea_info *eabuf, unsigned int buf_len,
>  		       const struct path *path, bool get_write)
>  {
> -	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  	char *attr_name = NULL, *value;
>  	int rc = 0;
>  	unsigned int next = 0;
> @@ -3333,16 +3332,14 @@ static int smb2_set_ea(struct smb2_ea_info *eabuf, unsigned int buf_len,
>  		value = (char *)&eabuf->name + eabuf->EaNameLength + 1;
>  
>  		if (!eabuf->EaValueLength) {
> -			rc = ksmbd_vfs_casexattr_len(idmap,
> -						     path->dentry,
> +			rc = ksmbd_vfs_casexattr_len(path,
>  						     attr_name,
>  						     XATTR_USER_PREFIX_LEN +
>  						     eabuf->EaNameLength);
>  
>  			/* delete the EA only when it exits */
>  			if (rc > 0) {
> -				rc = ksmbd_vfs_remove_xattr(idmap,
> -							    path,
> +				rc = ksmbd_vfs_remove_xattr(path,
>  							    attr_name,
>  							    get_write);
>  
> @@ -3357,7 +3354,7 @@ static int smb2_set_ea(struct smb2_ea_info *eabuf, unsigned int buf_len,
>  			/* if the EA doesn't exist, just do nothing. */
>  			rc = 0;
>  		} else {
> -			rc = ksmbd_vfs_setxattr(idmap, path, attr_name, value,
> +			rc = ksmbd_vfs_setxattr(path, attr_name, value,
>  						le16_to_cpu(eabuf->EaValueLength),
>  						0, get_write);
>  			if (rc < 0) {
> @@ -3394,7 +3391,6 @@ static noinline int smb2_set_stream_name_xattr(const struct path *path,
>  					       struct ksmbd_file *fp,
>  					       char *stream_name, int s_type)
>  {
> -	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  	size_t xattr_stream_size;
>  	char *xattr_stream_name;
>  	int rc;
> @@ -3410,8 +3406,7 @@ static noinline int smb2_set_stream_name_xattr(const struct path *path,
>  	fp->stream.size = xattr_stream_size;
>  
>  	/* Check if there is stream prefix in xattr space */
> -	rc = ksmbd_vfs_casexattr_len(idmap,
> -				     path->dentry,
> +	rc = ksmbd_vfs_casexattr_len(path,
>  				     xattr_stream_name,
>  				     xattr_stream_size);
>  	if (rc >= 0)
> @@ -3438,7 +3433,7 @@ static noinline int smb2_set_stream_name_xattr(const struct path *path,
>  				0x00, 0x00, 0x01, 0x00,	/* version */
>  				[15] = 0x80,		/* backup time */
>  			};
> -			rc = ksmbd_vfs_setxattr(idmap, path, xattr_stream_name,
> +			rc = ksmbd_vfs_setxattr(path, xattr_stream_name,
>  						(void *)afpinfo_empty,
>  						sizeof(afpinfo_empty), 0, false);
>  			return rc < 0 ? rc : 0;
> @@ -3447,7 +3442,7 @@ static noinline int smb2_set_stream_name_xattr(const struct path *path,
>  		return -EBADF;
>  	}
>  
> -	rc = ksmbd_vfs_setxattr(idmap, path, xattr_stream_name, NULL, 0, 0, false);
> +	rc = ksmbd_vfs_setxattr(path, xattr_stream_name, NULL, 0, 0, false);
>  	if (rc < 0)
>  		pr_err("Failed to store XATTR stream name :%d\n", rc);
>  	return 0;
> @@ -3462,8 +3457,7 @@ static noinline int smb2_set_stream_name_xattr(const struct path *path,
>   */
>  static loff_t ksmbd_stream_eof(struct ksmbd_file *fp)
>  {
> -	ssize_t slen = ksmbd_vfs_casexattr_len(file_mnt_idmap(fp->filp),
> -					       fp->filp->f_path.dentry,
> +	ssize_t slen = ksmbd_vfs_casexattr_len(&fp->filp->f_path,
>  					       fp->stream.name,
>  					       fp->stream.size);
>  	return slen < 0 ? 0 : (loff_t)slen;
> @@ -3471,12 +3465,11 @@ static loff_t ksmbd_stream_eof(struct ksmbd_file *fp)
>  
>  static int smb2_remove_smb_xattrs(const struct path *path)
>  {
> -	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  	char *name, *xattr_list = NULL;
>  	ssize_t xattr_list_len;
>  	int err = 0;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(path->dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len < 0) {
>  		goto out;
>  	} else if (!xattr_list_len) {
> @@ -3491,8 +3484,7 @@ static int smb2_remove_smb_xattrs(const struct path *path)
>  		if (!strncmp(name, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN) &&
>  		    !strncmp(&name[XATTR_USER_PREFIX_LEN], STREAM_PREFIX,
>  			     STREAM_PREFIX_LEN)) {
> -			err = ksmbd_vfs_remove_xattr(idmap, path,
> -						     name, true);
> +			err = ksmbd_vfs_remove_xattr(path, name, true);
>  			if (err)
>  				ksmbd_debug(SMB, "remove xattr failed : %s\n",
>  					    name);
> @@ -3538,7 +3530,7 @@ static void smb2_new_xattrs(struct ksmbd_tree_connect *tcon, const struct path *
>  	da.flags = XATTR_DOSINFO_ATTRIB | XATTR_DOSINFO_CREATE_TIME |
>  		XATTR_DOSINFO_ITIME;
>  
> -	rc = ksmbd_vfs_set_dos_attrib_xattr(mnt_idmap(path->mnt), path, &da, true);
> +	rc = ksmbd_vfs_set_dos_attrib_xattr(path, &da, true);
>  	if (rc)
>  		ksmbd_debug(SMB, "failed to store file attribute into xattr\n");
>  }
> @@ -3547,6 +3539,7 @@ static bool smb2_parent_compressed(struct ksmbd_tree_connect *tcon,
>  				   const struct path *path)
>  {
>  	struct dentry *parent = dget_parent(path->dentry);
> +	struct path parent_path = { .mnt = path->mnt, .dentry = parent };
>  	struct file_kattr fa = { .flags_valid = true };
>  	struct xattr_dos_attrib da;
>  	bool compressed = false;
> @@ -3558,7 +3551,7 @@ static bool smb2_parent_compressed(struct ksmbd_tree_connect *tcon,
>  		goto out;
>  	}
>  
> -	rc = ksmbd_vfs_get_dos_attrib_xattr(mnt_idmap(path->mnt), parent, &da);
> +	rc = ksmbd_vfs_get_dos_attrib_xattr(&parent_path, &da);
>  	if (rc > 0 && da.attr & FILE_ATTRIBUTE_COMPRESSED)
>  		compressed = true;
>  
> @@ -3578,8 +3571,7 @@ static void smb2_update_xattrs(struct ksmbd_tree_connect *tcon,
>  	fp->f_ci->m_fattr &= ~(FILE_ATTRIBUTE_HIDDEN_LE | FILE_ATTRIBUTE_SYSTEM_LE);
>  
>  	/* get FileAttributes from XATTR_NAME_DOS_ATTRIBUTE */
> -	rc = ksmbd_vfs_get_dos_attrib_xattr(mnt_idmap(path->mnt),
> -					    path->dentry, &da);
> +	rc = ksmbd_vfs_get_dos_attrib_xattr(path, &da);
>  	if (rc > 0) {
>  		if (store_dos_attrs) {
>  			fp->f_ci->m_fattr = cpu_to_le32(da.attr);
> @@ -4524,8 +4516,7 @@ int smb2_open(struct ksmbd_work *work)
>  
>  			if (test_share_config_flag(tcon->share_conf,
>  						   KSMBD_SHARE_FLAG_STORE_DOS_ATTRS) &&
> -			    ksmbd_vfs_get_dos_attrib_xattr(mnt_idmap(path.mnt),
> -							 path.dentry, &da) > 0 &&
> +			    ksmbd_vfs_get_dos_attrib_xattr(&path, &da) > 0 &&
>  			    da.attr & FILE_ATTRIBUTE_READONLY) {
>  				rsp->hdr.Status = STATUS_CANNOT_DELETE;
>  				rc = -EACCES;
> @@ -4863,7 +4854,6 @@ int smb2_open(struct ksmbd_work *work)
>  					}
>  
>  					rc = ksmbd_vfs_set_sd_xattr(conn,
> -								    idmap,
>  								    &path,
>  								    pntsd,
>  								    pntsd_size,
> @@ -5886,7 +5876,6 @@ static int process_query_dir_entries(struct smb2_query_dir_private *priv)
>  		ksmbd_kstat.kstat = &kstat;
>  		if (priv->info_level != FILE_NAMES_INFORMATION) {
>  			rc = ksmbd_vfs_fill_dentry_attrs(priv->work,
> -							 idmap,
>  							 dent,
>  							 &ksmbd_kstat);
>  			if (rc) {
> @@ -6428,7 +6417,6 @@ static int smb2_get_ea(struct ksmbd_work *work, struct ksmbd_file *fp,
>  	ssize_t buf_free_len, alignment_bytes, next_offset, rsp_data_cnt = 0;
>  	struct smb2_ea_info_req *ea_req = NULL;
>  	const struct path *path;
> -	struct mnt_idmap *idmap = file_mnt_idmap(fp->filp);
>  
>  	if (!(fp->daccess & FILE_READ_EA_LE)) {
>  		pr_err("Not permitted to read ext attr : 0x%x\n",
> @@ -6465,7 +6453,7 @@ static int smb2_get_ea(struct ksmbd_work *work, struct ksmbd_file *fp,
>  	if (buf_free_len < 0)
>  		return -EINVAL;
>  
> -	rc = ksmbd_vfs_listxattr(path->dentry, &xattr_list);
> +	rc = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (rc < 0) {
>  		rsp->hdr.Status = STATUS_INVALID_HANDLE;
>  		goto out;
> @@ -6511,8 +6499,7 @@ static int smb2_get_ea(struct ksmbd_work *work, struct ksmbd_file *fp,
>  		buf_free_len -= (offsetof(struct smb2_ea_info, name) +
>  				name_len + 1);
>  		/* bailout if xattr can't fit in buf_free_len */
> -		value_len = ksmbd_vfs_getxattr(idmap, path->dentry,
> -					       name, &buf);
> +		value_len = ksmbd_vfs_getxattr(path, name, &buf);
>  		if (value_len <= 0) {
>  			rc = -ENOENT;
>  			rsp->hdr.Status = STATUS_INVALID_HANDLE;
> @@ -6802,7 +6789,7 @@ static char *smb2_get_normalized_stream_name(struct ksmbd_file *fp)
>  	if (!ksmbd_stream_fd(fp))
>  		return NULL;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(fp->filp->f_path.dentry,
> +	xattr_list_len = ksmbd_vfs_listxattr(&fp->filp->f_path,
>  					     &xattr_list);
>  	if (xattr_list_len <= 0)
>  		goto out;
> @@ -6905,7 +6892,7 @@ static int get_file_stream_info(struct ksmbd_work *work,
>  	if (buf_free_len < 0)
>  		goto out;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(path->dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len < 0) {
>  		goto out;
>  	} else if (!xattr_list_len) {
> @@ -6950,8 +6937,7 @@ static int get_file_stream_info(struct ksmbd_work *work,
>  		streamlen *= 2;
>  		kfree(stream_buf);
>  		file_info->StreamNameLength = cpu_to_le32(streamlen);
> -		slen = ksmbd_vfs_xattr_len(file_mnt_idmap(fp->filp),
> -					   path->dentry, stream_name);
> +		slen = ksmbd_vfs_xattr_len(path, stream_name);
>  		ssize = slen < 0 ? 0 : (loff_t)slen;
>  		file_info->StreamSize = cpu_to_le64(ssize);
>  		file_info->StreamAllocationSize = cpu_to_le64(ssize);
> @@ -7689,8 +7675,8 @@ static int smb2_get_info_sec(struct ksmbd_work *work,
>  
>  	if (test_share_config_flag(work->tcon->share_conf,
>  				   KSMBD_SHARE_FLAG_ACL_XATTR))
> -		ppntsd_size = ksmbd_vfs_get_sd_xattr(work->conn, idmap,
> -						     fp->filp->f_path.dentry,
> +		ppntsd_size = ksmbd_vfs_get_sd_xattr(work->conn,
> +						     &fp->filp->f_path,
>  						     &ppntsd);
>  
>  	/* Check if sd buffer size exceeds response buffer size */
> @@ -8051,8 +8037,7 @@ static int smb2_rename(struct ksmbd_work *work,
>  				goto out;
>  			}
>  
> -			stream_buf_len = ksmbd_vfs_getcasexattr(file_mnt_idmap(fp->filp),
> -								fp->filp->f_path.dentry,
> +			stream_buf_len = ksmbd_vfs_getcasexattr(&fp->filp->f_path,
>  								fp->stream.name,
>  								fp->stream.size,
>  								&stream_buf);
> @@ -8063,8 +8048,7 @@ static int smb2_rename(struct ksmbd_work *work,
>  			}
>  		}
>  
> -		rc = ksmbd_vfs_setxattr(file_mnt_idmap(fp->filp),
> -					&fp->filp->f_path,
> +		rc = ksmbd_vfs_setxattr(&fp->filp->f_path,
>  					xattr_stream_name,
>  					stream_buf, stream_buf_len, 0, true);
>  		kfree(stream_buf);
> @@ -8171,7 +8155,6 @@ static int set_file_basic_info(struct ksmbd_file *fp,
>  	struct iattr attrs;
>  	struct file *filp;
>  	struct inode *inode;
> -	struct mnt_idmap *idmap;
>  	__le32 attrs_mask = FILE_ATTRIBUTE_DIRECTORY_LE |
>  		FILE_ATTRIBUTE_COMPRESSED_LE;
>  	int rc = 0;
> @@ -8182,7 +8165,6 @@ static int set_file_basic_info(struct ksmbd_file *fp,
>  	attrs.ia_valid = 0;
>  	filp = fp->filp;
>  	inode = file_inode(filp);
> -	idmap = file_mnt_idmap(filp);
>  
>  	if (file_info->CreationTime)
>  		fp->create_time = le64_to_cpu(file_info->CreationTime);
> @@ -8227,7 +8209,7 @@ static int set_file_basic_info(struct ksmbd_file *fp,
>  		da.flags = XATTR_DOSINFO_ATTRIB | XATTR_DOSINFO_CREATE_TIME |
>  			XATTR_DOSINFO_ITIME;
>  
> -		rc = ksmbd_vfs_set_dos_attrib_xattr(idmap, &filp->f_path, &da,
> +		rc = ksmbd_vfs_set_dos_attrib_xattr(&filp->f_path, &da,
>  				true);
>  		if (rc)
>  			ksmbd_debug(SMB,
> @@ -10780,7 +10762,6 @@ static inline int fsctl_set_sparse(struct ksmbd_work *work, u64 id,
>  				   struct file_sparse *sparse)
>  {
>  	struct ksmbd_file *fp;
> -	struct mnt_idmap *idmap;
>  	int ret = 0;
>  	__le32 old_fattr;
>  
> @@ -10804,8 +10785,6 @@ static inline int fsctl_set_sparse(struct ksmbd_work *work, u64 id,
>  		goto out;
>  	}
>  
> -	idmap = file_mnt_idmap(fp->filp);
> -
>  	old_fattr = fp->f_ci->m_fattr;
>  	if (!sparse->SetSparse &&
>  	    (old_fattr & FILE_ATTRIBUTE_SPARSE_FILE_LE)) {
> @@ -10823,8 +10802,7 @@ static inline int fsctl_set_sparse(struct ksmbd_work *work, u64 id,
>  		const struct cred *saved_cred;
>  		struct xattr_dos_attrib da = {0};
>  
> -		ret = ksmbd_vfs_get_dos_attrib_xattr(idmap,
> -						     fp->filp->f_path.dentry, &da);
> +		ret = ksmbd_vfs_get_dos_attrib_xattr(&fp->filp->f_path, &da);
>  		if (ret <= 0) {
>  			da.version = 4;
>  			da.itime = fp->itime;
> @@ -10836,8 +10814,7 @@ static inline int fsctl_set_sparse(struct ksmbd_work *work, u64 id,
>  		da.attr = le32_to_cpu(fp->f_ci->m_fattr);
>  		da.flags |= XATTR_DOSINFO_ATTRIB;
>  		saved_cred = override_creds(fp->filp->f_cred);
> -		ret = ksmbd_vfs_set_dos_attrib_xattr(idmap,
> -						     &fp->filp->f_path,
> +		ret = ksmbd_vfs_set_dos_attrib_xattr(&fp->filp->f_path,
>  						     &da, true);
>  		revert_creds(saved_cred);
>  		if (ret)
> diff --git a/fs/smb/server/smb_common.c b/fs/smb/server/smb_common.c
> index 086a1b85e5f4..2cc8e24dcd6c 100644
> --- a/fs/smb/server/smb_common.c
> +++ b/fs/smb/server/smb_common.c
> @@ -467,7 +467,6 @@ int ksmbd_populate_dot_dotdot_entries(struct ksmbd_work *work, int info_level,
>  {
>  	int i, rc = 0;
>  	struct ksmbd_conn *conn = work->conn;
> -	struct mnt_idmap *idmap = file_mnt_idmap(dir->filp);
>  
>  	for (i = 0; i < 2; i++) {
>  		struct kstat kstat;
> @@ -493,7 +492,6 @@ int ksmbd_populate_dot_dotdot_entries(struct ksmbd_work *work, int info_level,
>  
>  			ksmbd_kstat.kstat = &kstat;
>  			rc = ksmbd_vfs_fill_dentry_attrs(work,
> -							 idmap,
>  							 dentry,
>  							 &ksmbd_kstat);
>  			if (rc)
> diff --git a/fs/smb/server/smbacl.c b/fs/smb/server/smbacl.c
> index fcace71b0a29..f81e06918cfb 100644
> --- a/fs/smb/server/smbacl.c
> +++ b/fs/smb/server/smbacl.c
> @@ -1199,8 +1199,8 @@ int smb_inherit_dacl(struct ksmbd_conn *conn,
>  	struct smb_acl *parent_pdacl;
>  	struct smb_ntsd *parent_pntsd = NULL;
>  	struct smb_sid owner_sid, group_sid;
> -	struct dentry *parent = path->dentry->d_parent;
> -	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
> +	struct path parent_path = { .mnt = path->mnt,
> +				    .dentry = path->dentry->d_parent };
>  	int inherited_flags = 0, flags = 0, i, nt_size = 0, pdacl_size;
>  	int rc = 0, pntsd_type, ppntsd_size, acl_len, aces_size;
>  	unsigned int dacloffset;
> @@ -1209,8 +1209,8 @@ int smb_inherit_dacl(struct ksmbd_conn *conn,
>  	char *aces_base;
>  	bool is_dir = S_ISDIR(d_inode(path->dentry)->i_mode);
>  
> -	ppntsd_size = ksmbd_vfs_get_sd_xattr(conn, idmap,
> -					    parent, &parent_pntsd);
> +	ppntsd_size = ksmbd_vfs_get_sd_xattr(conn, &parent_path,
> +					    &parent_pntsd);
>  	if (ppntsd_size <= 0)
>  		return -ENOENT;
>  
> @@ -1427,7 +1427,7 @@ int smb_inherit_dacl(struct ksmbd_conn *conn,
>  			pntsd_size += sizeof(struct smb_acl) + nt_size;
>  		}
>  
> -		ksmbd_vfs_set_sd_xattr(conn, idmap, path, pntsd, pntsd_size, false);
> +		ksmbd_vfs_set_sd_xattr(conn, path, pntsd, pntsd_size, false);
>  		kfree(pntsd);
>  	}
>  
> @@ -1476,8 +1476,7 @@ int smb_check_perm_dacl(struct ksmbd_conn *conn, const struct path *path,
>  	vfsuid_t vfsuid;
>  
>  	ksmbd_debug(SMB, "check permission using windows acl\n");
> -	pntsd_size = ksmbd_vfs_get_sd_xattr(conn, idmap,
> -					    path->dentry, &pntsd);
> +	pntsd_size = ksmbd_vfs_get_sd_xattr(conn, path, &pntsd);
>  	if (pntsd_size <= 0 || !pntsd)
>  		goto err_out;
>  
> @@ -1701,7 +1700,7 @@ int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
>  	newattrs.ia_valid |= ATTR_MODE;
>  	newattrs.ia_mode = (inode->i_mode & ~0777) | (fattr.cf_mode & 0777);
>  
> -	ksmbd_vfs_remove_acl_xattrs(idmap, path);
> +	ksmbd_vfs_remove_acl_xattrs(path);
>  	/* Update posix acls */
>  	if (IS_ENABLED(CONFIG_FS_POSIX_ACL) && fattr.cf_dacls) {
>  		rc = set_posix_acl(idmap, path->dentry,
> @@ -1732,8 +1731,8 @@ int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
>  
>  	if (test_share_config_flag(tcon->share_conf, KSMBD_SHARE_FLAG_ACL_XATTR)) {
>  		/* Update WinACL in xattr */
> -		ksmbd_vfs_remove_sd_xattrs(idmap, path);
> -		ksmbd_vfs_set_sd_xattr(conn, idmap, path, pntsd, ntsd_len,
> +		ksmbd_vfs_remove_sd_xattrs(path);
> +		ksmbd_vfs_set_sd_xattr(conn, path, pntsd, ntsd_len,
>  				get_write);
>  	}
>  
> diff --git a/fs/smb/server/tests/smbacl_kunit.c b/fs/smb/server/tests/smbacl_kunit.c
> index 33496b4d31a3..0e918b72f94f 100644
> --- a/fs/smb/server/tests/smbacl_kunit.c
> +++ b/fs/smb/server/tests/smbacl_kunit.c
> @@ -221,8 +221,7 @@ static void ksmbd_smb_check_perm_dacl_boundary_test(struct kunit *test)
>  				mk_vma_flags(VMA_NORESERVE_BIT));
>  	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, file);
>  
> -	rc = ksmbd_vfs_set_sd_xattr(NULL, mnt_idmap(file->f_path.mnt),
> -				    &file->f_path, pntsd, ntsd_size,
> +	rc = ksmbd_vfs_set_sd_xattr(NULL, &file->f_path, pntsd, ntsd_size,
>  				    false);
>  	KUNIT_EXPECT_EQ(test, 0, rc);
>  	if (rc)
> @@ -263,8 +262,7 @@ ksmbd_smb_check_perm_dacl_maximal_boundary_test(struct kunit *test)
>  				mk_vma_flags(VMA_NORESERVE_BIT));
>  	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, file);
>  
> -	rc = ksmbd_vfs_set_sd_xattr(NULL, mnt_idmap(file->f_path.mnt),
> -				    &file->f_path, pntsd, ntsd_size,
> +	rc = ksmbd_vfs_set_sd_xattr(NULL, &file->f_path, pntsd, ntsd_size,
>  				    false);
>  	KUNIT_EXPECT_EQ(test, 0, rc);
>  	if (rc)
> diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
> index db0f2de2bab3..eb904cf9ef2d 100644
> --- a/fs/smb/server/vfs.c
> +++ b/fs/smb/server/vfs.c
> @@ -217,14 +217,14 @@ int ksmbd_vfs_mkdir(struct ksmbd_work *work, const char *name, umode_t mode)
>  	return err;
>  }
>  
> -ssize_t ksmbd_vfs_getcasexattr(struct mnt_idmap *idmap,
> -			       struct dentry *dentry, char *attr_name,
> +ssize_t ksmbd_vfs_getcasexattr(const struct path *path,
> +			       char *attr_name,
>  			       int attr_name_len, char **attr_value)
>  {
>  	char *name, *xattr_list = NULL;
>  	ssize_t value_len = -ENOENT, xattr_list_len;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len <= 0)
>  		goto out;
>  
> @@ -234,8 +234,7 @@ ssize_t ksmbd_vfs_getcasexattr(struct mnt_idmap *idmap,
>  		if (strncasecmp(attr_name, name, attr_name_len))
>  			continue;
>  
> -		value_len = ksmbd_vfs_getxattr(idmap,
> -					       dentry,
> +		value_len = ksmbd_vfs_getxattr(path,
>  					       name,
>  					       attr_value);
>  		if (value_len < 0)
> @@ -259,8 +258,7 @@ static int ksmbd_vfs_stream_read(struct ksmbd_file *fp, char *buf, loff_t *pos,
>  		    *pos, count);
>  
>  	saved_cred = override_creds(fp->filp->f_cred);
> -	v_len = ksmbd_vfs_getcasexattr(file_mnt_idmap(fp->filp),
> -				       fp->filp->f_path.dentry,
> +	v_len = ksmbd_vfs_getcasexattr(&fp->filp->f_path,
>  				       fp->stream.name,
>  				       fp->stream.size,
>  				       &stream_buf);
> @@ -387,7 +385,6 @@ static int ksmbd_vfs_stream_write(struct ksmbd_file *fp, char *buf, loff_t *pos,
>  {
>  	const struct cred *saved_cred;
>  	char *stream_buf = NULL, *wbuf;
> -	struct mnt_idmap *idmap = file_mnt_idmap(fp->filp);
>  	size_t size;
>  	ssize_t v_len;
>  	int err = 0;
> @@ -407,8 +404,7 @@ static int ksmbd_vfs_stream_write(struct ksmbd_file *fp, char *buf, loff_t *pos,
>  	}
>  
>  	saved_cred = override_creds(fp->filp->f_cred);
> -	v_len = ksmbd_vfs_getcasexattr(idmap,
> -				       fp->filp->f_path.dentry,
> +	v_len = ksmbd_vfs_getcasexattr(&fp->filp->f_path,
>  				       fp->stream.name,
>  				       fp->stream.size,
>  				       &stream_buf);
> @@ -433,8 +429,7 @@ static int ksmbd_vfs_stream_write(struct ksmbd_file *fp, char *buf, loff_t *pos,
>  
>  	memcpy(&stream_buf[*pos], buf, count);
>  
> -	err = ksmbd_vfs_setxattr(idmap,
> -				 &fp->filp->f_path,
> +	err = ksmbd_vfs_setxattr(&fp->filp->f_path,
>  				 fp->stream.name,
>  				 (void *)stream_buf,
>  				 size,
> @@ -813,17 +808,17 @@ int ksmbd_vfs_truncate(struct ksmbd_work *work,
>  
>  /**
>   * ksmbd_vfs_listxattr() - vfs helper for smb list extended attributes
> - * @dentry:	dentry of file for listing xattrs
> + * @path:	path of file for listing xattrs
>   * @list:	destination buffer
>   *
>   * Return:	xattr list length on success, otherwise error
>   */
> -ssize_t ksmbd_vfs_listxattr(struct dentry *dentry, char **list)
> +ssize_t ksmbd_vfs_listxattr(const struct path *path, char **list)
>  {
>  	ssize_t size;
>  	char *vlist = NULL;
>  
> -	size = vfs_listxattr(dentry, NULL, 0);
> +	size = vfs_listxattr(path, NULL, 0);
>  	if (size <= 0)
>  		return size;
>  
> @@ -832,7 +827,7 @@ ssize_t ksmbd_vfs_listxattr(struct dentry *dentry, char **list)
>  		return -ENOMEM;
>  
>  	*list = vlist;
> -	size = vfs_listxattr(dentry, vlist, size);
> +	size = vfs_listxattr(path, vlist, size);
>  	if (size < 0) {
>  		ksmbd_debug(VFS, "listxattr failed\n");
>  		kvfree(vlist);
> @@ -842,30 +837,27 @@ ssize_t ksmbd_vfs_listxattr(struct dentry *dentry, char **list)
>  	return size;
>  }
>  
> -ssize_t ksmbd_vfs_xattr_len(struct mnt_idmap *idmap,
> -			    struct dentry *dentry, char *xattr_name)
> +ssize_t ksmbd_vfs_xattr_len(const struct path *path, char *xattr_name)
>  {
> -	return vfs_getxattr(idmap, dentry, xattr_name, NULL, 0);
> +	return vfs_getxattr(path, xattr_name, NULL, 0);
>  }
>  
>  /**
>   * ksmbd_vfs_getxattr() - vfs helper for smb get extended attributes value
> - * @idmap:	idmap
> - * @dentry:	dentry of file for getting xattrs
> + * @path:	path of file for getting xattrs
>   * @xattr_name:	name of xattr name to query
>   * @xattr_buf:	destination buffer xattr value
>   *
>   * Return:	read xattr value length on success, otherwise error
>   */
> -ssize_t ksmbd_vfs_getxattr(struct mnt_idmap *idmap,
> -			   struct dentry *dentry,
> +ssize_t ksmbd_vfs_getxattr(const struct path *path,
>  			   char *xattr_name, char **xattr_buf)
>  {
>  	ssize_t xattr_len;
>  	char *buf;
>  
>  	*xattr_buf = NULL;
> -	xattr_len = ksmbd_vfs_xattr_len(idmap, dentry, xattr_name);
> +	xattr_len = ksmbd_vfs_xattr_len(path, xattr_name);
>  	if (xattr_len < 0)
>  		return xattr_len;
>  
> @@ -873,8 +865,7 @@ ssize_t ksmbd_vfs_getxattr(struct mnt_idmap *idmap,
>  	if (!buf)
>  		return -ENOMEM;
>  
> -	xattr_len = vfs_getxattr(idmap, dentry, xattr_name,
> -				 (void *)buf, xattr_len);
> +	xattr_len = vfs_getxattr(path, xattr_name, (void *)buf, xattr_len);
>  	if (xattr_len > 0)
>  		*xattr_buf = buf;
>  	else
> @@ -884,7 +875,6 @@ ssize_t ksmbd_vfs_getxattr(struct mnt_idmap *idmap,
>  
>  /**
>   * ksmbd_vfs_setxattr() - vfs helper for smb set extended attributes value
> - * @idmap:	idmap of the relevant mount
>   * @path:	path of dentry to set XATTR at
>   * @attr_name:	xattr name for setxattr
>   * @attr_value:	xattr value to set
> @@ -894,8 +884,7 @@ ssize_t ksmbd_vfs_getxattr(struct mnt_idmap *idmap,
>   *
>   * Return:	0 on success, otherwise error
>   */
> -int ksmbd_vfs_setxattr(struct mnt_idmap *idmap,
> -		       const struct path *path, const char *attr_name,
> +int ksmbd_vfs_setxattr(const struct path *path, const char *attr_name,
>  		       void *attr_value, size_t attr_size, int flags,
>  		       bool get_write)
>  {
> @@ -907,8 +896,7 @@ int ksmbd_vfs_setxattr(struct mnt_idmap *idmap,
>  			return err;
>  	}
>  
> -	err = vfs_setxattr(idmap,
> -			   path->dentry,
> +	err = vfs_setxattr(path,
>  			   attr_name,
>  			   attr_value,
>  			   attr_size,
> @@ -1178,8 +1166,7 @@ int ksmbd_vfs_query_allocated_ranges(struct ksmbd_file *fp, loff_t start,
>  	return ret;
>  }
>  
> -int ksmbd_vfs_remove_xattr(struct mnt_idmap *idmap,
> -			   const struct path *path, char *attr_name,
> +int ksmbd_vfs_remove_xattr(const struct path *path, char *attr_name,
>  			   bool get_write)
>  {
>  	int err;
> @@ -1190,7 +1177,7 @@ int ksmbd_vfs_remove_xattr(struct mnt_idmap *idmap,
>  			return err;
>  	}
>  
> -	err = vfs_removexattr(idmap, path->dentry, attr_name);
> +	err = vfs_removexattr(path, attr_name);
>  
>  	if (get_write == true)
>  		mnt_drop_write(path->mnt);
> @@ -1472,14 +1459,13 @@ struct dentry *ksmbd_vfs_kern_path_create(struct ksmbd_work *work,
>  	return dent;
>  }
>  
> -int ksmbd_vfs_remove_acl_xattrs(struct mnt_idmap *idmap,
> -				const struct path *path)
> +int ksmbd_vfs_remove_acl_xattrs(const struct path *path)
>  {
>  	char *name, *xattr_list = NULL;
>  	ssize_t xattr_list_len;
>  	int err = 0;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(path->dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len < 0) {
>  		goto out;
>  	} else if (!xattr_list_len) {
> @@ -1499,7 +1485,8 @@ int ksmbd_vfs_remove_acl_xattrs(struct mnt_idmap *idmap,
>  			     sizeof(XATTR_NAME_POSIX_ACL_ACCESS) - 1) ||
>  		    !strncmp(name, XATTR_NAME_POSIX_ACL_DEFAULT,
>  			     sizeof(XATTR_NAME_POSIX_ACL_DEFAULT) - 1)) {
> -			err = vfs_remove_acl(idmap, path->dentry, name);
> +			err = vfs_remove_acl(mnt_idmap(path->mnt),
> +					     path->dentry, name);
>  			if (err)
>  				ksmbd_debug(SMB,
>  					    "remove acl xattr failed : %s\n", name);
> @@ -1512,13 +1499,13 @@ int ksmbd_vfs_remove_acl_xattrs(struct mnt_idmap *idmap,
>  	return err;
>  }
>  
> -int ksmbd_vfs_remove_sd_xattrs(struct mnt_idmap *idmap, const struct path *path)
> +int ksmbd_vfs_remove_sd_xattrs(const struct path *path)
>  {
>  	char *name, *xattr_list = NULL;
>  	ssize_t xattr_list_len;
>  	int err = 0;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(path->dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len < 0) {
>  		goto out;
>  	} else if (!xattr_list_len) {
> @@ -1531,7 +1518,7 @@ int ksmbd_vfs_remove_sd_xattrs(struct mnt_idmap *idmap, const struct path *path)
>  		ksmbd_debug(SMB, "%s, len %zd\n", name, strlen(name));
>  
>  		if (!strncmp(name, XATTR_NAME_SD, XATTR_NAME_SD_LEN)) {
> -			err = ksmbd_vfs_remove_xattr(idmap, path, name, true);
> +			err = ksmbd_vfs_remove_xattr(path, name, true);
>  			if (err)
>  				ksmbd_debug(SMB, "remove xattr failed : %s\n", name);
>  		}
> @@ -1607,7 +1594,6 @@ static struct xattr_smb_acl *ksmbd_vfs_make_xattr_posix_acl(struct mnt_idmap *id
>  }
>  
>  int ksmbd_vfs_set_sd_xattr(struct ksmbd_conn *conn,
> -			   struct mnt_idmap *idmap,
>  			   const struct path *path,
>  			   struct smb_ntsd *pntsd, int len,
>  			   bool get_write)
> @@ -1618,6 +1604,7 @@ int ksmbd_vfs_set_sd_xattr(struct ksmbd_conn *conn,
>  	struct xattr_smb_acl *smb_acl, *def_smb_acl = NULL;
>  	struct dentry *dentry = path->dentry;
>  	struct inode *inode = d_inode(dentry);
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  
>  	acl.version = 4;
>  	acl.hash_type = XATTR_SD_HASH_TYPE_SHA256;
> @@ -1659,7 +1646,7 @@ int ksmbd_vfs_set_sd_xattr(struct ksmbd_conn *conn,
>  		goto out;
>  	}
>  
> -	rc = ksmbd_vfs_setxattr(idmap, path,
> +	rc = ksmbd_vfs_setxattr(path,
>  				XATTR_NAME_SD, sd_ndr.data,
>  				sd_ndr.offset, 0, get_write);
>  	if (rc < 0)
> @@ -1675,19 +1662,19 @@ int ksmbd_vfs_set_sd_xattr(struct ksmbd_conn *conn,
>  EXPORT_SYMBOL_IF_KUNIT(ksmbd_vfs_set_sd_xattr);
>  
>  int ksmbd_vfs_get_sd_xattr(struct ksmbd_conn *conn,
> -			   struct mnt_idmap *idmap,
> -			   struct dentry *dentry,
> +			   const struct path *path,
>  			   struct smb_ntsd **pntsd)
>  {
>  	int rc;
>  	struct ndr n;
> -	struct inode *inode = d_inode(dentry);
> +	struct inode *inode = d_inode(path->dentry);
>  	struct ndr acl_ndr = {0};
>  	struct xattr_ntacl acl = {0};
>  	struct xattr_smb_acl *smb_acl = NULL, *def_smb_acl = NULL;
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  	__u8 cmp_hash[XATTR_SD_HASH_SIZE] = {0};
>  
> -	rc = ksmbd_vfs_getxattr(idmap, dentry, XATTR_NAME_SD, &n.data);
> +	rc = ksmbd_vfs_getxattr(path, XATTR_NAME_SD, &n.data);
>  	if (rc <= 0)
>  		return rc;
>  
> @@ -1744,8 +1731,7 @@ int ksmbd_vfs_get_sd_xattr(struct ksmbd_conn *conn,
>  	return rc;
>  }
>  
> -int ksmbd_vfs_set_dos_attrib_xattr(struct mnt_idmap *idmap,
> -				   const struct path *path,
> +int ksmbd_vfs_set_dos_attrib_xattr(const struct path *path,
>  				   struct xattr_dos_attrib *da,
>  				   bool get_write)
>  {
> @@ -1756,7 +1742,7 @@ int ksmbd_vfs_set_dos_attrib_xattr(struct mnt_idmap *idmap,
>  	if (err)
>  		goto out;
>  
> -	err = ksmbd_vfs_setxattr(idmap, path, XATTR_NAME_DOS_ATTRIBUTE,
> +	err = ksmbd_vfs_setxattr(path, XATTR_NAME_DOS_ATTRIBUTE,
>  				 (void *)n.data, n.offset, 0, get_write);
>  	if (err)
>  		ksmbd_debug(SMB, "failed to store dos attribute in xattr\n");
> @@ -1766,14 +1752,13 @@ int ksmbd_vfs_set_dos_attrib_xattr(struct mnt_idmap *idmap,
>  	return err;
>  }
>  
> -int ksmbd_vfs_get_dos_attrib_xattr(struct mnt_idmap *idmap,
> -				   struct dentry *dentry,
> +int ksmbd_vfs_get_dos_attrib_xattr(const struct path *path,
>  				   struct xattr_dos_attrib *da)
>  {
>  	struct ndr n;
>  	int err;
>  
> -	err = ksmbd_vfs_getxattr(idmap, dentry, XATTR_NAME_DOS_ATTRIBUTE,
> +	err = ksmbd_vfs_getxattr(path, XATTR_NAME_DOS_ATTRIBUTE,
>  				 (char **)&n.data);
>  	if (err > 0) {
>  		n.length = err;
> @@ -1822,7 +1807,6 @@ void *ksmbd_vfs_init_kstat(char **p, struct ksmbd_kstat *ksmbd_kstat)
>  }
>  
>  int ksmbd_vfs_fill_dentry_attrs(struct ksmbd_work *work,
> -				struct mnt_idmap *idmap,
>  				struct dentry *dentry,
>  				struct ksmbd_kstat *ksmbd_kstat)
>  {
> @@ -1856,7 +1840,7 @@ int ksmbd_vfs_fill_dentry_attrs(struct ksmbd_work *work,
>  				   KSMBD_SHARE_FLAG_STORE_DOS_ATTRS)) {
>  		struct xattr_dos_attrib da;
>  
> -		rc = ksmbd_vfs_get_dos_attrib_xattr(idmap, dentry, &da);
> +		rc = ksmbd_vfs_get_dos_attrib_xattr(&path, &da);
>  		if (rc > 0) {
>  			ksmbd_kstat->file_attributes = cpu_to_le32(da.attr);
>  			ksmbd_kstat->create_time = da.create_time;
> @@ -1879,7 +1863,7 @@ int ksmbd_vfs_fill_dentry_attrs(struct ksmbd_work *work,
>  		char *xattr_list = NULL, *name;
>  		ssize_t xattr_list_len;
>  
> -		xattr_list_len = ksmbd_vfs_listxattr(dentry, &xattr_list);
> +		xattr_list_len = ksmbd_vfs_listxattr(&path, &xattr_list);
>  		if (xattr_list_len > 0) {
>  			for (name = xattr_list;
>  			     name - xattr_list < xattr_list_len;
> @@ -1897,14 +1881,14 @@ int ksmbd_vfs_fill_dentry_attrs(struct ksmbd_work *work,
>  	return 0;
>  }
>  
> -ssize_t ksmbd_vfs_casexattr_len(struct mnt_idmap *idmap,
> -				struct dentry *dentry, char *attr_name,
> +ssize_t ksmbd_vfs_casexattr_len(const struct path *path,
> +				char *attr_name,
>  				int attr_name_len)
>  {
>  	char *name, *xattr_list = NULL;
>  	ssize_t value_len = -ENOENT, xattr_list_len;
>  
> -	xattr_list_len = ksmbd_vfs_listxattr(dentry, &xattr_list);
> +	xattr_list_len = ksmbd_vfs_listxattr(path, &xattr_list);
>  	if (xattr_list_len <= 0)
>  		goto out;
>  
> @@ -1914,7 +1898,7 @@ ssize_t ksmbd_vfs_casexattr_len(struct mnt_idmap *idmap,
>  		if (strncasecmp(attr_name, name, attr_name_len))
>  			continue;
>  
> -		value_len = ksmbd_vfs_xattr_len(idmap, dentry, name);
> +		value_len = ksmbd_vfs_xattr_len(path, name);
>  		break;
>  	}
>  
> @@ -2067,8 +2051,7 @@ int ksmbd_vfs_copy_file_ranges(struct ksmbd_work *work,
>  
>  		saved_cred = override_creds(src_fp->filp->f_cred);
>  		src_file_size = ksmbd_vfs_casexattr_len(
> -				file_mnt_idmap(src_fp->filp),
> -				src_fp->filp->f_path.dentry,
> +				&src_fp->filp->f_path,
>  				src_fp->stream.name, src_fp->stream.size);
>  		revert_creds(saved_cred);
>  		if (src_file_size < 0)
> @@ -2386,7 +2369,7 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
>  	if (fp->f_ci->m_fattr != old_fattr) {
>  		struct xattr_dos_attrib da = {0};
>  
> -		rc = ksmbd_vfs_get_dos_attrib_xattr(idmap, dentry, &da);
> +		rc = ksmbd_vfs_get_dos_attrib_xattr(&fp->filp->f_path, &da);
>  		if (rc <= 0) {
>  			da.version = 4;
>  			da.itime = fp->itime;
> @@ -2397,8 +2380,7 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
>  
>  		da.attr = le32_to_cpu(fp->f_ci->m_fattr);
>  		da.flags |= XATTR_DOSINFO_ATTRIB;
> -		rc = ksmbd_vfs_set_dos_attrib_xattr(idmap,
> -						    &fp->filp->f_path,
> +		rc = ksmbd_vfs_set_dos_attrib_xattr(&fp->filp->f_path,
>  						    &da, true);
>  		if (rc)
>  			rc = 0;
> diff --git a/fs/smb/server/vfs.h b/fs/smb/server/vfs.h
> index 566c670c90be..a0cf77a7a2c7 100644
> --- a/fs/smb/server/vfs.h
> +++ b/fs/smb/server/vfs.h
> @@ -103,27 +103,24 @@ int ksmbd_vfs_copy_file_ranges(struct ksmbd_work *work,
>  			       unsigned int *chunk_count_written,
>  			       unsigned int *chunk_size_written,
>  			       loff_t  *total_size_written);
> -ssize_t ksmbd_vfs_listxattr(struct dentry *dentry, char **list);
> -ssize_t ksmbd_vfs_getxattr(struct mnt_idmap *idmap,
> -			   struct dentry *dentry,
> +ssize_t ksmbd_vfs_listxattr(const struct path *path, char **list);
> +ssize_t ksmbd_vfs_getxattr(const struct path *path,
>  			   char *xattr_name,
>  			   char **xattr_buf);
> -ssize_t ksmbd_vfs_xattr_len(struct mnt_idmap *idmap,
> -			    struct dentry *dentry, char *xattr_name);
> -ssize_t ksmbd_vfs_getcasexattr(struct mnt_idmap *idmap,
> -			       struct dentry *dentry, char *attr_name,
> +ssize_t ksmbd_vfs_xattr_len(const struct path *path,
> +			    char *xattr_name);
> +ssize_t ksmbd_vfs_getcasexattr(const struct path *path,
> +			       char *attr_name,
>  			       int attr_name_len, char **attr_value);
> -ssize_t ksmbd_vfs_casexattr_len(struct mnt_idmap *idmap,
> -				struct dentry *dentry, char *attr_name,
> +ssize_t ksmbd_vfs_casexattr_len(const struct path *path,
> +				char *attr_name,
>  				int attr_name_len);
> -int ksmbd_vfs_setxattr(struct mnt_idmap *idmap,
> -		       const struct path *path, const char *attr_name,
> +int ksmbd_vfs_setxattr(const struct path *path, const char *attr_name,
>  		       void *attr_value, size_t attr_size, int flags,
>  		       bool get_write);
>  int ksmbd_vfs_xattr_stream_name(char *stream_name, char **xattr_stream_name,
>  				size_t *xattr_stream_name_size, int s_type);
> -int ksmbd_vfs_remove_xattr(struct mnt_idmap *idmap,
> -			   const struct path *path, char *attr_name,
> +int ksmbd_vfs_remove_xattr(const struct path *path, char *attr_name,
>  			   bool get_write);
>  int ksmbd_vfs_kern_path(struct ksmbd_work *work, char *name,
>  			unsigned int flags,
> @@ -152,29 +149,23 @@ int ksmbd_vfs_query_allocated_ranges(struct ksmbd_file *fp, loff_t start,
>  int ksmbd_vfs_unlink(struct file *filp);
>  void *ksmbd_vfs_init_kstat(char **p, struct ksmbd_kstat *ksmbd_kstat);
>  int ksmbd_vfs_fill_dentry_attrs(struct ksmbd_work *work,
> -				struct mnt_idmap *idmap,
>  				struct dentry *dentry,
>  				struct ksmbd_kstat *ksmbd_kstat);
>  void ksmbd_vfs_posix_lock_wait(struct file_lock *flock);
>  void ksmbd_vfs_posix_lock_unblock(struct file_lock *flock);
> -int ksmbd_vfs_remove_acl_xattrs(struct mnt_idmap *idmap,
> -				const struct path *path);
> -int ksmbd_vfs_remove_sd_xattrs(struct mnt_idmap *idmap, const struct path *path);
> +int ksmbd_vfs_remove_acl_xattrs(const struct path *path);
> +int ksmbd_vfs_remove_sd_xattrs(const struct path *path);
>  int ksmbd_vfs_set_sd_xattr(struct ksmbd_conn *conn,
> -			   struct mnt_idmap *idmap,
>  			   const struct path *path,
>  			   struct smb_ntsd *pntsd, int len,
>  			   bool get_write);
>  int ksmbd_vfs_get_sd_xattr(struct ksmbd_conn *conn,
> -			   struct mnt_idmap *idmap,
> -			   struct dentry *dentry,
> +			   const struct path *path,
>  			   struct smb_ntsd **pntsd);
> -int ksmbd_vfs_set_dos_attrib_xattr(struct mnt_idmap *idmap,
> -				   const struct path *path,
> +int ksmbd_vfs_set_dos_attrib_xattr(const struct path *path,
>  				   struct xattr_dos_attrib *da,
>  				   bool get_write);
> -int ksmbd_vfs_get_dos_attrib_xattr(struct mnt_idmap *idmap,
> -				   struct dentry *dentry,
> +int ksmbd_vfs_get_dos_attrib_xattr(const struct path *path,
>  				   struct xattr_dos_attrib *da);
>  int ksmbd_vfs_set_init_posix_acl(struct mnt_idmap *idmap,
>  				 const struct path *path);
> diff --git a/fs/smb/server/vfs_cache.c b/fs/smb/server/vfs_cache.c
> index a96b764c4db5..b5700c6f096f 100644
> --- a/fs/smb/server/vfs_cache.c
> +++ b/fs/smb/server/vfs_cache.c
> @@ -538,8 +538,7 @@ static void __ksmbd_inode_close(struct ksmbd_file *fp)
>  			const struct cred *saved_cred;
>  
>  			saved_cred = override_creds(filp->f_cred);
> -			err = ksmbd_vfs_remove_xattr(file_mnt_idmap(filp),
> -						     &filp->f_path,
> +			err = ksmbd_vfs_remove_xattr(&filp->f_path,
>  						     fp->stream.name,
>  						     true);
>  			revert_creds(saved_cred);
> diff --git a/fs/xattr.c b/fs/xattr.c
> index d58979115200..818d6652b6d9 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -285,8 +285,7 @@ int __vfs_setxattr_noperm(struct mnt_idmap *idmap,
>   * __vfs_setxattr_locked - set an extended attribute while holding the inode
>   * lock
>   *
> - *  @idmap: idmap of the mount of the target inode
> - *  @dentry: object to perform setxattr on
> + *  @path: object to perform setxattr on
>   *  @name: xattr name to set
>   *  @value: value to set @name to
>   *  @size: size of @value
> @@ -295,10 +294,12 @@ int __vfs_setxattr_noperm(struct mnt_idmap *idmap,
>   *  a delegation was broken on, NULL if none.
>   */
>  int
> -__vfs_setxattr_locked(struct mnt_idmap *idmap, struct dentry *dentry,
> -		      const char *name, const void *value, size_t size,
> -		      int flags, struct delegated_inode *delegated_inode)
> +__vfs_setxattr_locked(const struct path *path, const char *name,
> +		      const void *value, size_t size, int flags,
> +		      struct delegated_inode *delegated_inode)
>  {
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> @@ -324,9 +325,11 @@ __vfs_setxattr_locked(struct mnt_idmap *idmap, struct dentry *dentry,
>  EXPORT_SYMBOL_GPL(__vfs_setxattr_locked);
>  
>  int
> -vfs_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
> -	     const char *name, const void *value, size_t size, int flags)
> +vfs_setxattr(const struct path *path, const char *name, const void *value,
> +	     size_t size, int flags)
>  {
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = dentry->d_inode;
>  	struct delegated_inode delegated_inode = { };
>  	const void  *orig_value = value;
> @@ -341,7 +344,7 @@ vfs_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
>  
>  retry_deleg:
>  	inode_lock(inode);
> -	error = __vfs_setxattr_locked(idmap, dentry, name, value, size,
> +	error = __vfs_setxattr_locked(path, name, value, size,
>  				      flags, &delegated_inode);
>  	inode_unlock(inode);
>  
> @@ -448,9 +451,11 @@ __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
>  EXPORT_SYMBOL(__vfs_getxattr);
>  
>  ssize_t
> -vfs_getxattr(struct mnt_idmap *idmap, struct dentry *dentry,
> -	     const char *name, void *value, size_t size)
> +vfs_getxattr(const struct path *path, const char *name, void *value,
> +	     size_t size)
>  {
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> @@ -482,12 +487,12 @@ EXPORT_SYMBOL_GPL(vfs_getxattr);
>  
>  /**
>   * vfs_listxattr - retrieve \0 separated list of xattr names
> - * @dentry: the dentry from whose inode the xattr names are retrieved
> + * @path: the path from whose inode the xattr names are retrieved
>   * @list: buffer to store xattr names into
>   * @size: size of the buffer
>   *
>   * This function returns the names of all xattrs associated with the
> - * inode of @dentry.
> + * inode of @path->dentry.
>   *
>   * Note, for legacy reasons the vfs_listxattr() function lists POSIX
>   * ACLs as well. Since POSIX ACLs are decoupled from IOP_XATTR the
> @@ -503,8 +508,9 @@ EXPORT_SYMBOL_GPL(vfs_getxattr);
>   *         negative error code.
>   */
>  ssize_t
> -vfs_listxattr(struct dentry *dentry, char *list, size_t size)
> +vfs_listxattr(const struct path *path, char *list, size_t size)
>  {
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = d_inode(dentry);
>  	ssize_t error;
>  
> @@ -550,17 +556,17 @@ EXPORT_SYMBOL(__vfs_removexattr);
>   * __vfs_removexattr_locked - set an extended attribute while holding the inode
>   * lock
>   *
> - *  @idmap: idmap of the mount of the target inode
> - *  @dentry: object to perform setxattr on
> + *  @path: object to perform removexattr on
>   *  @name: name of xattr to remove
>   *  @delegated_inode: on return, will contain an inode pointer that
>   *  a delegation was broken on, NULL if none.
>   */
>  int
> -__vfs_removexattr_locked(struct mnt_idmap *idmap,
> -			 struct dentry *dentry, const char *name,
> +__vfs_removexattr_locked(const struct path *path, const char *name,
>  			 struct delegated_inode *delegated_inode)
>  {
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> @@ -589,17 +595,16 @@ __vfs_removexattr_locked(struct mnt_idmap *idmap,
>  EXPORT_SYMBOL_GPL(__vfs_removexattr_locked);
>  
>  int
> -vfs_removexattr(struct mnt_idmap *idmap, struct dentry *dentry,
> -		const char *name)
> +vfs_removexattr(const struct path *path, const char *name)
>  {
> +	struct dentry *dentry = path->dentry;
>  	struct inode *inode = dentry->d_inode;
>  	struct delegated_inode delegated_inode = { };
>  	int error;
>  
>  retry_deleg:
>  	inode_lock(inode);
> -	error = __vfs_removexattr_locked(idmap, dentry,
> -					 name, &delegated_inode);
> +	error = __vfs_removexattr_locked(path, name, &delegated_inode);
>  	inode_unlock(inode);
>  
>  	if (is_delegated(&delegated_inode)) {
> @@ -652,14 +657,13 @@ int setxattr_copy(const char __user *name, struct kernel_xattr_ctx *ctx)
>  	return error;
>  }
>  
> -static int do_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
> -		struct kernel_xattr_ctx *ctx)
> +static int do_setxattr(const struct path *path, struct kernel_xattr_ctx *ctx)
>  {
>  	if (is_posix_acl_xattr(ctx->kname->name))
> -		return do_set_acl(idmap, dentry, ctx->kname->name,
> -				  ctx->kvalue, ctx->size);
> +		return do_set_acl(mnt_idmap(path->mnt), path->dentry,
> +				  ctx->kname->name, ctx->kvalue, ctx->size);
>  
> -	return vfs_setxattr(idmap, dentry, ctx->kname->name,
> +	return vfs_setxattr(path, ctx->kname->name,
>  			ctx->kvalue, ctx->size, ctx->flags);
>  }
>  
> @@ -669,7 +673,7 @@ int file_setxattr(struct file *f, struct kernel_xattr_ctx *ctx)
>  
>  	if (!error) {
>  		audit_file(f);
> -		error = do_setxattr(file_mnt_idmap(f), f->f_path.dentry, ctx);
> +		error = do_setxattr(&f->f_path, ctx);
>  		mnt_drop_write_file(f);
>  	}
>  	return error;
> @@ -687,7 +691,7 @@ int filename_setxattr(int dfd, struct filename *filename,
>  		return error;
>  	error = mnt_want_write(path.mnt);
>  	if (!error) {
> -		error = do_setxattr(mnt_idmap(path.mnt), path.dentry, ctx);
> +		error = do_setxattr(&path, ctx);
>  		mnt_drop_write(path.mnt);
>  	}
>  	path_put(&path);
> @@ -787,8 +791,7 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
>   * Extended attribute GET operations
>   */
>  static ssize_t
> -do_getxattr(struct mnt_idmap *idmap, struct dentry *d,
> -	struct kernel_xattr_ctx *ctx)
> +do_getxattr(const struct path *path, struct kernel_xattr_ctx *ctx)
>  {
>  	ssize_t error;
>  	char *kname = ctx->kname->name;
> @@ -803,9 +806,10 @@ do_getxattr(struct mnt_idmap *idmap, struct dentry *d,
>  	}
>  
>  	if (is_posix_acl_xattr(kname))
> -		error = do_get_acl(idmap, d, kname, kvalue, ctx->size);
> +		error = do_get_acl(mnt_idmap(path->mnt), path->dentry,
> +				   kname, kvalue, ctx->size);
>  	else
> -		error = vfs_getxattr(idmap, d, kname, kvalue, ctx->size);
> +		error = vfs_getxattr(path, kname, kvalue, ctx->size);
>  	if (error > 0) {
>  		if (ctx->size && copy_to_user(ctx->value, kvalue, error))
>  			error = -EFAULT;
> @@ -822,7 +826,7 @@ do_getxattr(struct mnt_idmap *idmap, struct dentry *d,
>  ssize_t file_getxattr(struct file *f, struct kernel_xattr_ctx *ctx)
>  {
>  	audit_file(f);
> -	return do_getxattr(file_mnt_idmap(f), f->f_path.dentry, ctx);
> +	return do_getxattr(&f->f_path, ctx);
>  }
>  
>  ssize_t filename_getxattr(int dfd, struct filename *filename,
> @@ -834,7 +838,7 @@ ssize_t filename_getxattr(int dfd, struct filename *filename,
>  	error = filename_lookup(dfd, filename, lookup_flags, &path, NULL);
>  	if (error)
>  		return error;
> -	error = do_getxattr(mnt_idmap(path.mnt), path.dentry, ctx);
> +	error = do_getxattr(&path, ctx);
>  	path_put(&path);
>  	if (retry_estale(error, lookup_flags)) {
>  		lookup_flags |= LOOKUP_REVAL;
> @@ -925,7 +929,7 @@ SYSCALL_DEFINE4(fgetxattr, int, fd, const char __user *, name,
>   * Extended attribute LIST operations
>   */
>  static ssize_t
> -listxattr(struct dentry *d, char __user *list, size_t size)
> +listxattr(const struct path *path, char __user *list, size_t size)
>  {
>  	ssize_t error;
>  	char *klist = NULL;
> @@ -938,7 +942,7 @@ listxattr(struct dentry *d, char __user *list, size_t size)
>  			return -ENOMEM;
>  	}
>  
> -	error = vfs_listxattr(d, klist, size);
> +	error = vfs_listxattr(path, klist, size);
>  	if (error > 0) {
>  		if (size && copy_to_user(list, klist, error))
>  			error = -EFAULT;
> @@ -957,7 +961,7 @@ static
>  ssize_t file_listxattr(struct file *f, char __user *list, size_t size)
>  {
>  	audit_file(f);
> -	return listxattr(f->f_path.dentry, list, size);
> +	return listxattr(&f->f_path, list, size);
>  }
>  
>  static
> @@ -971,7 +975,7 @@ ssize_t filename_listxattr(int dfd, struct filename *filename,
>  	error = filename_lookup(dfd, filename, lookup_flags, &path, NULL);
>  	if (error)
>  		return error;
> -	error = listxattr(path.dentry, list, size);
> +	error = listxattr(&path, list, size);
>  	path_put(&path);
>  	if (retry_estale(error, lookup_flags)) {
>  		lookup_flags |= LOOKUP_REVAL;
> @@ -1029,11 +1033,12 @@ SYSCALL_DEFINE3(flistxattr, int, fd, char __user *, list, size_t, size)
>   * Extended attribute REMOVE operations
>   */
>  static long
> -removexattr(struct mnt_idmap *idmap, struct dentry *d, const char *name)
> +removexattr(const struct path *path, const char *name)
>  {
>  	if (is_posix_acl_xattr(name))
> -		return vfs_remove_acl(idmap, d, name);
> -	return vfs_removexattr(idmap, d, name);
> +		return vfs_remove_acl(mnt_idmap(path->mnt), path->dentry,
> +				      name);
> +	return vfs_removexattr(path, name);
>  }
>  
>  static int file_removexattr(struct file *f, struct xattr_name *kname)
> @@ -1042,8 +1047,7 @@ static int file_removexattr(struct file *f, struct xattr_name *kname)
>  
>  	if (!error) {
>  		audit_file(f);
> -		error = removexattr(file_mnt_idmap(f),
> -				    f->f_path.dentry, kname->name);
> +		error = removexattr(&f->f_path, kname->name);
>  		mnt_drop_write_file(f);
>  	}
>  	return error;
> @@ -1061,7 +1065,7 @@ static int filename_removexattr(int dfd, struct filename *filename,
>  		return error;
>  	error = mnt_want_write(path.mnt);
>  	if (!error) {
> -		error = removexattr(mnt_idmap(path.mnt), path.dentry, kname->name);
> +		error = removexattr(&path, kname->name);
>  		mnt_drop_write(path.mnt);
>  	}
>  	path_put(&path);
> diff --git a/include/linux/xattr.h b/include/linux/xattr.h
> index 54ac3cbc133f..85042618fd81 100644
> --- a/include/linux/xattr.h
> +++ b/include/linux/xattr.h
> @@ -77,22 +77,22 @@ struct xattr {
>  };
>  
>  ssize_t __vfs_getxattr(struct dentry *, struct inode *, const char *, void *, size_t);
> -ssize_t vfs_getxattr(struct mnt_idmap *, struct dentry *, const char *,
> -		     void *, size_t);
> -ssize_t vfs_listxattr(struct dentry *d, char *list, size_t size);
> +ssize_t vfs_getxattr(const struct path *path, const char *name, void *value,
> +		     size_t size);
> +ssize_t vfs_listxattr(const struct path *path, char *list, size_t size);
>  int __vfs_setxattr(struct mnt_idmap *, struct dentry *, struct inode *,
>  		   const char *, const void *, size_t, int);
>  int __vfs_setxattr_noperm(struct mnt_idmap *, struct dentry *,
>  			  const char *, const void *, size_t, int);
> -int __vfs_setxattr_locked(struct mnt_idmap *, struct dentry *,
> -			  const char *, const void *, size_t, int,
> -			  struct delegated_inode *);
> -int vfs_setxattr(struct mnt_idmap *, struct dentry *, const char *,
> -		 const void *, size_t, int);
> +int __vfs_setxattr_locked(const struct path *path, const char *name,
> +			  const void *value, size_t size, int flags,
> +			  struct delegated_inode *delegated_inode);
> +int vfs_setxattr(const struct path *path, const char *name,
> +		 const void *value, size_t size, int flags);
>  int __vfs_removexattr(struct mnt_idmap *, struct dentry *, const char *);
> -int __vfs_removexattr_locked(struct mnt_idmap *, struct dentry *,
> -			     const char *, struct delegated_inode *);
> -int vfs_removexattr(struct mnt_idmap *, struct dentry *, const char *);
> +int __vfs_removexattr_locked(const struct path *path, const char *name,
> +			     struct delegated_inode *delegated_inode);
> +int vfs_removexattr(const struct path *path, const char *name);
>  
>  ssize_t generic_listxattr(struct dentry *dentry, char *buffer, size_t buffer_size);
>  int vfs_getxattr_alloc(struct mnt_idmap *idmap,
> diff --git a/security/integrity/evm/evm_crypto.c b/security/integrity/evm/evm_crypto.c
> index 1c41af2f91a6..3d759efd3c6c 100644
> --- a/security/integrity/evm/evm_crypto.c
> +++ b/security/integrity/evm/evm_crypto.c
> @@ -237,7 +237,7 @@ static int evm_calc_hmac_or_hash(struct dentry *dentry,
>  	size_t xattr_size = 0;
>  	char *xattr_value = NULL;
>  	int error;
> -	int size, user_space_size;
> +	int size;
>  	bool ima_present = false;
>  	u64 i_version = 0;
>  
> @@ -287,12 +287,6 @@ static int evm_calc_hmac_or_hash(struct dentry *dentry,
>  		if (size < 0)
>  			continue;
>  
> -		user_space_size = vfs_getxattr(&nop_mnt_idmap, dentry,
> -					       xattr->name, NULL, 0);
> -		if (user_space_size != size)
> -			pr_debug("file %s: xattr %s size mismatch (kernel: %d, user: %d)\n",
> -				 dentry->d_name.name, xattr->name, size,
> -				 user_space_size);
>  		error = 0;
>  		xattr_size = size;
>  		crypto_shash_update(desc, (const u8 *)xattr_value, xattr_size);
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 8af024fe4fb5..1d06b08f3c41 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -7168,8 +7168,8 @@ static int selinux_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen
>   */
>  static int selinux_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
>  {
> -	return __vfs_setxattr_locked(&nop_mnt_idmap, path->dentry,
> -				     XATTR_NAME_SELINUX, ctx, ctxlen, 0, NULL);
> +	return __vfs_setxattr_locked(path, XATTR_NAME_SELINUX,
> +				     ctx, ctxlen, 0, NULL);
>  }
>  
>  static int selinux_inode_getsecctx(struct inode *inode, struct lsm_context *cp)
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index d9e9f4a52567..e517809c230d 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -4980,8 +4980,8 @@ static int smack_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
>  
>  static int smack_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
>  {
> -	return __vfs_setxattr_locked(&nop_mnt_idmap, path->dentry,
> -				     XATTR_NAME_SMACK, ctx, ctxlen, 0, NULL);
> +	return __vfs_setxattr_locked(path, XATTR_NAME_SMACK,
> +				     ctx, ctxlen, 0, NULL);
>  }
>  
>  static int smack_inode_getsecctx(struct inode *inode, struct lsm_context *cp)
