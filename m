Received: from sonic305-27.consmr.mail.ne1.yahoo.com (sonic305-27.consmr.mail.ne1.yahoo.com [66.163.185.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF3434A3F06
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 15:50:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.163.185.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791301857; cv=none; b=IDvOZVrU8NPDXjji/e7Ep0KDAry/cv4TK2sa8l7DUcdeSXNjchdFHn21J98uF9ex2GN1jyyI0hp+UXg4npc7AKjizMk6hDXa9MyY2i/H0IXVdiP13sLVL3ELmSXgtBNtcsDEkZLPDw/CaMaBGIjyCAPyLuBOqGt3k0p+twgP06U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791301857; c=relaxed/simple;
	bh=EheR1hmf6/Ev3iO8zIIEknwXzGh5275L3B9/AxtcZ+s=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=EJv9wEN5VvEF1ofOKaBDTDATEVQD+uBN18NqbvOdBnx4Rv8+Gf7Nbf6HtRjZZc5DnZsYRn/nXi/thf4U2a/ZWZrZ0Cayed1/gtjQt0a7RYMHU1JWbNvFdezx+FY+6yiVVZbRlopbPzMYOnGzybOIIVlxx4S2Mrg+L6jguAOeqSw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com; spf=pass smtp.mailfrom=schaufler-ca.com; dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b=UZfV3tON; arc=none smtp.client-ip=66.163.185.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="UZfV3tON"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1791301848; bh=In0HrnRjC0SQ8uSLS948ZfF+aHZwrdC2RfKhVM1BaVU=; h=Date:Subject:To:Cc:References:From:In-Reply-To:From:Subject:Reply-To; b=UZfV3tONQNSl5S3BZlLyAcaspco9G2cysE31uURe+3yErCynXyik8Wio+r5bccsdPhxdEuUuzd7CT6Qr5MdaHEktUwU4tW0YCOBcLU464zmFicUgWJGPiipCzMJ+fhFHJOLj+qHwNrF8K8jlOMYv8tNB+xNhsBWpSWVWzXfImB38e+xLLqFoHg9xaa/oQ7XBoLV2NMR3AcizWIFn6Cue3Uq/WcGLkEZGngCd6eULn4eUO8h1k8jFeRIo2ZHjaSGYF7Ze4nmRsM3pSA0bJ1lBOtzS3R/BbffrsNcGLt6q9RQw7akweJIYNFZI4PA4B2GCZ+RFEDbOK5/BcctgjWYb/w==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1791301848; bh=U2Wm3+ad1OHbYxIGTgbUp/TxR4QdPCyOMu7N33NIVnz=; h=X-Sonic-MF:Date:Subject:To:From:From:Subject; b=BBphlDA/0CBHMVPgU2Q7zww1C4LiZg7ZsNtsga6dXSxyH/1N0RIDU4qlZwsgCwrTjMA0fTIb9a7+rRGctGCddMJ/joW/ROWAkMQNjTk8dX0w/PAkRcmkiEAU/IfRxLOLz8XFOqR7PuiubyizOrXzP9bOfOOi2SjDJpAoV4MUO4VBc72m66uB/1aLkLGdg6L+9yJlCnFHupS17ONOS5+LbBPqdkuReyBgZLPGB3hS/blt3rgGTC0tiXfRd6N4stVNKqlNNf4a9IYyAvwVyNALmkCePZmj1zLN6z0BQ4PQWE8NYv9CrRUxuJ6ozzeJ1qtb14giMUgnjZo5R+6QUo+uRQ==
X-YMail-OSG: 12QZ3EUVM1mvDQlcxYZXldfO5rSekIBwMsvbLf0NDjQP6AnCtfnVTQNdvWfOf0J
 93fqh6RW9AOmZtVzqatN.80sTuj8Yf0QB98V9uUSxbgcgNpp9tbgyqkiD1K2BPN4o8SVD5ViqN_X
 gsXAQofdVDPr2zBwaq8ozjSfI9mnbFeF_zCn6gmV7NZsQofQfQZEqH9.bXVObgPkO4MQeBLUDtPI
 ZY8eB0Z8Q1JOSYd0.pu9fRdKcMp_TSxvhsHACW0GgPzzp1RDPlBwGfTwPytWACoA4EB7HGFu8NFW
 ORr.oXUHSj0DEOESUeg6mfeP0lqSxa9Ii_Tv84xOJcSSkd5TtNs9LkkkHiZnCJV6a2MLNKelJlKq
 dTwUIQDHSuMTRevGtpNL1WK57izjzOJKqxmpFJvalR2yK26zPFRyqSW8PmoutNFayKolG0m3upcX
 SJ0MFM61bIE5mElH88jae_4tFLKODQWmuJByRIMZgGE_0eyAI7jbTd67TT_yqPDBjVYDMJqbTOnk
 qoKHXZUa1Ul89a.Yr.vm8TO2oczz.I360Wi9UcH0Lr4nZqd.503ilsgvjkJEQcXED89feVBP4TKy
 H56nynAjgco5rC2sOuS0JUk9i.FS13mheAA6eS3ulNdeVSdlLV1dM6as5x0BbEaimTCh0WPq4aFf
 AEDuvxuZ46eBgOaUZmC_I9xrYhWMNppp8B0zLn.Vq.4liihxHaW6Ew15Ek9QXomnOz2y99J.itFp
 wbfvwur9YPQnbYkHSGSynbOSbz.zwW4HhUMm5N2DI3x0iBUTCM9HSRHnn6_K_ffLNy9te9vYq2kM
 pFo8E9qe8lPp5kL_dmp1q_zMA6xCI_3PQsWH2talsDK7RoUhjtmDi7Y.1_wU1p61g11SgMsM2Ubv
 PXGNSW1EcWYNR0Czn5GIHe3BtbzYYwh7dUaqF16NKGy6K4XmFAJy9g6tE2iCQiGiFAShBB5znCp0
 QcJvBp0Mp9finI.PqM8VYOwV26PDPCmdm_JvTUYZIwRm91EqDu6BqSZaPeT0Y0Yvy8sQ9T5o6hia
 Jf5lpjNVhpP_5E7P67z1HaOr9_w1YD18XNDEh_KHCYODDpbDxD99uF4PsH1s1m8lJwBaLpOdWyoE
 F0qjRTf5UIn_JirFUiHAe6Up3rZ5Jdp5rh2X4isVXxXL4bbuxlqM_gGEE2RBaY6ltIdBQ0GIbZBT
 dbYp3bMvfF_q.skNBoxubsX1QyiUzx0fuzETYBBG7CqxpyaGlUorLh34pPGFvL2iJ0Pxuf3lGh7Y
 hRQCnsRwkw7Ae.lK9C.Qv4FLwaeM2p51MVNpMgPGR2PGhlZ.KLrKI4kGtDIzzI5G6dluMlMSxDfZ
 XcFdrMJzlLmveLcCRjEs1XOEUwUVGD5cpXCVTkJfL0NiTCWmcOphYNYGgw2mw4UFeapHp8hy5e1_
 62L85fGtYxLidMzyulooqyRXpuKiwoFTq0W2GO40.tUitBBPFHiyAByUa6cVi3hct8i1FBjzw6rC
 4X34olOFGDJ0rWScH11TeSeufzxRM1CaVXHD8k7u46gfTS9e5ATA2voAqb7sb6rECwVOZYWMjdWV
 ku3Hb8__zDu2J6jSmFnhchYWaH934QFgmbUTjh5MvzvD8TAth474RNDFZrYFfE9gDkLwYu2ufCii
 0HNVICGW5Z7oMs_MvrmBo4_EiKcl.B6TqUvtPdUwwly1dlby3DClhWo_Liil2D3QScNSCZ4vdTOS
 NyBHJIn5D5al1Vqfi1qHbDWuKnsIQqGDYL0ZZZtdNCx0J7zK62RedeBiLdikZRc3SJAKjkUq3SBN
 U278Y9zv3oQIsNrXVEI7LinaGiz93T2DptLp1KkgRehMGTMrzVz6nZQpXt3fuUCMRnEpw3_ozxwI
 3z94rmRGDFvUk3VsThm5ml8wim8wdu5uxeg24e3m_GPvIZsQLY0dO8ioutGnA1XFscIhfE0nq3qS
 PwV8a.MYffvzhYPk4_YdoSdWTWi4TxtwqmrZ5SdnYq.yqE_4LZHB86yWVBtx.hS0pUJQk.SuI4nd
 f3Cz32JctTVwMGOAPWXxMSa4sfL0ia3RrxgWYr1gvng2OcbevvpJAXwusvsZIsyDY7.mrPQcxXB3
 IjORPWA1U8hp9J7LNf_QQQHN.7Onb9GIazIqw76sHgnIK2X39Db8ggpsGus_p1ppyt81TrLuHvzD
 .e5wOwqup1lVwkezrv4u8Kw6JqBC7KXTLtWZW2cpsJLur1aqfpK0AE.s1SJ6o9EWX5_sE02HHOHk
 UVOCnvvImJwBcE1x3Li0eUyUIoqmL5hmO1D3Zkz2sLIPZEyqAhJyWcYcQKL6Mii9zupM-
X-Sonic-MF: <casey@schaufler-ca.com>
X-Sonic-ID: 2e35ecc7-e47d-4d0e-b617-632020e93310
Received: from sonic.gate.mail.ne1.yahoo.com by sonic305.consmr.mail.ne1.yahoo.com with HTTP; Tue, 6 Oct 2026 15:50:48 +0000
Received: by hermes--production-gq1-fd7994565-ftb5j (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID b0571d5bbbc1cca81cf8719e87a92cf0;
          Tue, 06 Oct 2026 15:30:08 +0000 (UTC)
Message-ID: <113bf656-867b-4b96-a8c3-4ae4735c0159@schaufler-ca.com>
Date: Tue, 6 Oct 2026 08:30:05 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC -next 07/12] LSM: pass struct path to the inode posix
 acl hooks
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
 <20260924104831.1081137-8-caixinchen1@huawei.com>
Content-Language: en-US
From: Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <20260924104831.1081137-8-caixinchen1@huawei.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Mailer: WebService/1.1.26668 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

On 9/24/2026 3:48 AM, Cai Xinchen wrote:
> The inode_set_acl, inode_get_acl and inode_remove_acl hooks are
> called from fs/posix_acl.c, whose helpers now hold a struct path and
> used to derive the idmap and dentry from it just for the hook calls.
>
> Convert the hooks and their SELinux, Smack, EVM and IMA
> implementations to take a const struct path.  The implementations
> derive the idmap and dentry they still need from the path, so this
> is a purely mechanical change with no behavior change.
>
> Assisted-by: opencode: glm-5.3
> Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>

The Smack changes appear sane.
Acked-by: Casey Schaufler <casey@schaufler-ca.com>

> ---
>  fs/posix_acl.c                        |  6 ++---
>  include/linux/lsm_hook_defs.h         | 12 ++++-----
>  include/linux/security.h              | 20 +++++----------
>  security/integrity/evm/evm_main.c     | 14 +++++-----
>  security/integrity/ima/ima_appraise.c |  8 +++---
>  security/security.c                   | 32 ++++++++++-------------
>  security/selinux/hooks.c              | 19 +++++++-------
>  security/smack/smack_lsm.c            | 37 ++++++++++++---------------
>  8 files changed, 66 insertions(+), 82 deletions(-)
>
> diff --git a/fs/posix_acl.c b/fs/posix_acl.c
> index be1643e18a6a..72e77540a0e9 100644
> --- a/fs/posix_acl.c
> +++ b/fs/posix_acl.c
> @@ -1128,7 +1128,7 @@ int vfs_set_acl(const struct path *path, const char *acl_name,
>  	if (error)
>  		goto out_inode_unlock;
>  
> -	error = security_inode_set_acl(idmap, dentry, acl_name, kacl);
> +	error = security_inode_set_acl(path, acl_name, kacl);
>  	if (error)
>  		goto out_inode_unlock;
>  
> @@ -1184,7 +1184,7 @@ struct posix_acl *vfs_get_acl(const struct path *path, const char *acl_name)
>  	 * The VFS has no restrictions on reading POSIX ACLs so calling
>  	 * something like xattr_permission() isn't needed. Only LSMs get a say.
>  	 */
> -	error = security_inode_get_acl(idmap, dentry, acl_name);
> +	error = security_inode_get_acl(path, acl_name);
>  	if (error)
>  		return ERR_PTR(error);
>  
> @@ -1236,7 +1236,7 @@ int vfs_remove_acl(const struct path *path, const char *acl_name)
>  	if (error)
>  		goto out_inode_unlock;
>  
> -	error = security_inode_remove_acl(idmap, dentry, acl_name);
> +	error = security_inode_remove_acl(path, acl_name);
>  	if (error)
>  		goto out_inode_unlock;
>  
> diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
> index 3a3512a3ee91..45cf0ca24260 100644
> --- a/include/linux/lsm_hook_defs.h
> +++ b/include/linux/lsm_hook_defs.h
> @@ -160,14 +160,14 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
>  	 const char *name)
>  LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
>  LSM_HOOK(int, 0, inode_file_getattr, struct dentry *dentry, struct file_kattr *fa)
> -LSM_HOOK(int, 0, inode_set_acl, struct mnt_idmap *idmap,
> -	 struct dentry *dentry, const char *acl_name, struct posix_acl *kacl)
> +LSM_HOOK(int, 0, inode_set_acl, const struct path *path,
> +	 const char *acl_name, struct posix_acl *kacl)
>  LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
>  	 const char *acl_name, struct posix_acl *kacl)
> -LSM_HOOK(int, 0, inode_get_acl, struct mnt_idmap *idmap,
> -	 struct dentry *dentry, const char *acl_name)
> -LSM_HOOK(int, 0, inode_remove_acl, struct mnt_idmap *idmap,
> -	 struct dentry *dentry, const char *acl_name)
> +LSM_HOOK(int, 0, inode_get_acl, const struct path *path,
> +	 const char *acl_name)
> +LSM_HOOK(int, 0, inode_remove_acl, const struct path *path,
> +	 const char *acl_name)
>  LSM_HOOK(void, LSM_RET_VOID, inode_post_remove_acl, struct mnt_idmap *idmap,
>  	 struct dentry *dentry, const char *acl_name)
>  LSM_HOOK(int, 0, inode_need_killpriv, struct dentry *dentry)
> diff --git a/include/linux/security.h b/include/linux/security.h
> index f5dc67a937bd..8b02b3bfe46d 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -435,15 +435,12 @@ int security_inode_getattr(const struct path *path);
>  int security_inode_setxattr(const struct path *path,
>  			    const char *name, const void *value,
>  			    size_t size, int flags);
> -int security_inode_set_acl(struct mnt_idmap *idmap,
> -			   struct dentry *dentry, const char *acl_name,
> -			   struct posix_acl *kacl);
> +int security_inode_set_acl(const struct path *path,
> +			   const char *acl_name, struct posix_acl *kacl);
>  void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
>  				 struct posix_acl *kacl);
> -int security_inode_get_acl(struct mnt_idmap *idmap,
> -			   struct dentry *dentry, const char *acl_name);
> -int security_inode_remove_acl(struct mnt_idmap *idmap,
> -			      struct dentry *dentry, const char *acl_name);
> +int security_inode_get_acl(const struct path *path, const char *acl_name);
> +int security_inode_remove_acl(const struct path *path, const char *acl_name);
>  void security_inode_post_remove_acl(struct mnt_idmap *idmap,
>  				    struct dentry *dentry,
>  				    const char *acl_name);
> @@ -1021,8 +1018,7 @@ static inline int security_inode_setxattr(const struct path *path,
>  	return cap_inode_setxattr(path, name, value, size, flags);
>  }
>  
> -static inline int security_inode_set_acl(struct mnt_idmap *idmap,
> -					 struct dentry *dentry,
> +static inline int security_inode_set_acl(const struct path *path,
>  					 const char *acl_name,
>  					 struct posix_acl *kacl)
>  {
> @@ -1034,15 +1030,13 @@ static inline void security_inode_post_set_acl(struct dentry *dentry,
>  					       struct posix_acl *kacl)
>  { }
>  
> -static inline int security_inode_get_acl(struct mnt_idmap *idmap,
> -					 struct dentry *dentry,
> +static inline int security_inode_get_acl(const struct path *path,
>  					 const char *acl_name)
>  {
>  	return 0;
>  }
>  
> -static inline int security_inode_remove_acl(struct mnt_idmap *idmap,
> -					    struct dentry *dentry,
> +static inline int security_inode_remove_acl(const struct path *path,
>  					    const char *acl_name)
>  {
>  	return 0;
> diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
> index 47ad39d64c76..c83befd32e99 100644
> --- a/security/integrity/evm/evm_main.c
> +++ b/security/integrity/evm/evm_main.c
> @@ -685,8 +685,7 @@ static inline int evm_inode_set_acl_change(struct mnt_idmap *idmap,
>  
>  /**
>   * evm_inode_set_acl - protect the EVM extended attribute from posix acls
> - * @idmap: idmap of the idmapped mount
> - * @dentry: pointer to the affected dentry
> + * @path: pointer to the affected object
>   * @acl_name: name of the posix acl
>   * @kacl: pointer to the posix acls
>   *
> @@ -696,10 +695,12 @@ static inline int evm_inode_set_acl_change(struct mnt_idmap *idmap,
>   *
>   * Return: zero on success, -EPERM on failure.
>   */
> -static int evm_inode_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
> +static int evm_inode_set_acl(const struct path *path,
>  			     const char *acl_name, struct posix_acl *kacl)
>  {
>  	enum integrity_status evm_status;
> +	struct dentry *dentry = path->dentry;
> +	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
>  
>  	/* Policy permits modification of the protected xattrs even though
>  	 * there's no HMAC key loaded
> @@ -738,8 +739,7 @@ static int evm_inode_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
>  
>  /**
>   * evm_inode_remove_acl - Protect the EVM extended attribute from posix acls
> - * @idmap: idmap of the mount
> - * @dentry: pointer to the affected dentry
> + * @path: pointer to the affected object
>   * @acl_name: name of the posix acl
>   *
>   * Prevent removing posix acls causing the EVM HMAC to be re-calculated
> @@ -748,10 +748,10 @@ static int evm_inode_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
>   *
>   * Return: zero on success, -EPERM on failure.
>   */
> -static int evm_inode_remove_acl(struct mnt_idmap *idmap, struct dentry *dentry,
> +static int evm_inode_remove_acl(const struct path *path,
>  				const char *acl_name)
>  {
> -	return evm_inode_set_acl(idmap, dentry, acl_name, NULL);
> +	return evm_inode_set_acl(path, acl_name, NULL);
>  }
>  
>  static void evm_reset_status(struct inode *inode)
> diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
> index 58ba674bc172..518faf04ddde 100644
> --- a/security/integrity/ima/ima_appraise.c
> +++ b/security/integrity/ima/ima_appraise.c
> @@ -793,11 +793,11 @@ static int ima_inode_setxattr(const struct path *path,
>  	return result;
>  }
>  
> -static int ima_inode_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
> +static int ima_inode_set_acl(const struct path *path,
>  			     const char *acl_name, struct posix_acl *kacl)
>  {
>  	if (evm_revalidate_status(acl_name))
> -		ima_reset_appraise_flags(d_backing_inode(dentry), -1);
> +		ima_reset_appraise_flags(d_backing_inode(path->dentry), -1);
>  
>  	return 0;
>  }
> @@ -818,10 +818,10 @@ static int ima_inode_removexattr(const struct path *path,
>  	return result;
>  }
>  
> -static int ima_inode_remove_acl(struct mnt_idmap *idmap, struct dentry *dentry,
> +static int ima_inode_remove_acl(const struct path *path,
>  				const char *acl_name)
>  {
> -	return ima_inode_set_acl(idmap, dentry, acl_name, NULL);
> +	return ima_inode_set_acl(path, acl_name, NULL);
>  }
>  
>  static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
> diff --git a/security/security.c b/security/security.c
> index 3a8892d8ca5c..74bcd8c0502c 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1987,8 +1987,7 @@ int security_inode_setxattr(const struct path *path,
>  
>  /**
>   * security_inode_set_acl() - Check if setting posix acls is allowed
> - * @idmap: idmap of the mount
> - * @dentry: file
> + * @path: file
>   * @acl_name: acl name
>   * @kacl: acl struct
>   *
> @@ -1997,13 +1996,12 @@ int security_inode_setxattr(const struct path *path,
>   *
>   * Return: Returns 0 if permission is granted.
>   */
> -int security_inode_set_acl(struct mnt_idmap *idmap,
> -			   struct dentry *dentry, const char *acl_name,
> -			   struct posix_acl *kacl)
> +int security_inode_set_acl(const struct path *path,
> +			   const char *acl_name, struct posix_acl *kacl)
>  {
> -	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
> +	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
>  		return 0;
> -	return call_int_hook(inode_set_acl, idmap, dentry, acl_name, kacl);
> +	return call_int_hook(inode_set_acl, path, acl_name, kacl);
>  }
>  
>  /**
> @@ -2025,8 +2023,7 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
>  
>  /**
>   * security_inode_get_acl() - Check if reading posix acls is allowed
> - * @idmap: idmap of the mount
> - * @dentry: file
> + * @path: file
>   * @acl_name: acl name
>   *
>   * Check permission before getting osix acls, the posix acls are identified by
> @@ -2034,18 +2031,16 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
>   *
>   * Return: Returns 0 if permission is granted.
>   */
> -int security_inode_get_acl(struct mnt_idmap *idmap,
> -			   struct dentry *dentry, const char *acl_name)
> +int security_inode_get_acl(const struct path *path, const char *acl_name)
>  {
> -	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
> +	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
>  		return 0;
> -	return call_int_hook(inode_get_acl, idmap, dentry, acl_name);
> +	return call_int_hook(inode_get_acl, path, acl_name);
>  }
>  
>  /**
>   * security_inode_remove_acl() - Check if removing a posix acl is allowed
> - * @idmap: idmap of the mount
> - * @dentry: file
> + * @path: file
>   * @acl_name: acl name
>   *
>   * Check permission before removing posix acls, the posix acls are identified
> @@ -2053,12 +2048,11 @@ int security_inode_get_acl(struct mnt_idmap *idmap,
>   *
>   * Return: Returns 0 if permission is granted.
>   */
> -int security_inode_remove_acl(struct mnt_idmap *idmap,
> -			      struct dentry *dentry, const char *acl_name)
> +int security_inode_remove_acl(const struct path *path, const char *acl_name)
>  {
> -	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
> +	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
>  		return 0;
> -	return call_int_hook(inode_remove_acl, idmap, dentry, acl_name);
> +	return call_int_hook(inode_remove_acl, path, acl_name);
>  }
>  
>  /**
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 5d98ec73df9f..45ece734463e 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3498,23 +3498,22 @@ static int selinux_inode_setxattr(const struct path *path,
>  			    &ad);
>  }
>  
> -static int selinux_inode_set_acl(struct mnt_idmap *idmap,
> -				 struct dentry *dentry, const char *acl_name,
> -				 struct posix_acl *kacl)
> +static int selinux_inode_set_acl(const struct path *path,
> +				 const char *acl_name, struct posix_acl *kacl)
>  {
> -	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
> +	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
>  }
>  
> -static int selinux_inode_get_acl(struct mnt_idmap *idmap,
> -				 struct dentry *dentry, const char *acl_name)
> +static int selinux_inode_get_acl(const struct path *path,
> +				 const char *acl_name)
>  {
> -	return dentry_has_perm(current_cred(), dentry, FILE__GETATTR);
> +	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
>  }
>  
> -static int selinux_inode_remove_acl(struct mnt_idmap *idmap,
> -				    struct dentry *dentry, const char *acl_name)
> +static int selinux_inode_remove_acl(const struct path *path,
> +				    const char *acl_name)
>  {
> -	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
> +	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
>  }
>  
>  static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 4adb2fd9cf70..7889f63ec739 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -1548,62 +1548,59 @@ static int smack_inode_removexattr(const struct path *path,
>   *
>   * Returns 0 if access is permitted, an error code otherwise
>   */
> -static int smack_inode_set_acl(struct mnt_idmap *idmap,
> -			       struct dentry *dentry, const char *acl_name,
> -			       struct posix_acl *kacl)
> +static int smack_inode_set_acl(const struct path *path,
> +			       const char *acl_name, struct posix_acl *kacl)
>  {
>  	struct smk_audit_info ad;
>  	int rc;
>  
>  	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
> -	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
> +	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
>  
> -	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
> -	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
> +	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
> +	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
>  	return rc;
>  }
>  
>  /**
>   * smack_inode_get_acl - Smack check for getting posix acls
> - * @idmap: idmap of the mnt this request came from
> - * @dentry: the object
> + * @path: the object
>   * @acl_name: name of the posix acl
>   *
>   * Returns 0 if access is permitted, an error code otherwise
>   */
> -static int smack_inode_get_acl(struct mnt_idmap *idmap,
> -			       struct dentry *dentry, const char *acl_name)
> +static int smack_inode_get_acl(const struct path *path,
> +			       const char *acl_name)
>  {
>  	struct smk_audit_info ad;
>  	int rc;
>  
>  	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
> -	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
> +	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
>  
> -	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_READ, &ad);
> -	rc = smk_bu_inode(d_backing_inode(dentry), MAY_READ, rc);
> +	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_READ, &ad);
> +	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_READ, rc);
>  	return rc;
>  }
>  
>  /**
>   * smack_inode_remove_acl - Smack check for getting posix acls
> - * @idmap: idmap of the mnt this request came from
> - * @dentry: the object
> + * @path: the object
>   * @acl_name: name of the posix acl
>   *
>   * Returns 0 if access is permitted, an error code otherwise
>   */
> -static int smack_inode_remove_acl(struct mnt_idmap *idmap,
> -				  struct dentry *dentry, const char *acl_name)
> +static int smack_inode_remove_acl(const struct path *path,
> +				  const char *acl_name)
>  {
>  	struct smk_audit_info ad;
>  	int rc;
>  
>  	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
> -	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
> +	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
>  
> -	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
> -	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
> +	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
> +	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
>  	return rc;
>  }
>  
