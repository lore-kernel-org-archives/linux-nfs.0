From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/10] NFS: Use C99 struct initializers in
	nfs4proc.c
Date: Thu, 31 May 2007 11:14:55 -0400
Message-ID: <465EE66F.8080909@oracle.com>
References: <20070525214105.28668.75496.stgit@schiele.1015granger.net>	
	<1180202462.5517.8.camel@heimdal.trondhjem.org>	
	<465C3459.7010302@oracle.com>
	<1180555947.6770.53.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070900050700050008080500"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtmNr-0001f6-Mk
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 08:16:15 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtmNt-00005m-0o
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 08:16:18 -0700
In-Reply-To: <1180555947.6770.53.camel@heimdal.trondhjem.org>
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
--------------070900050700050008080500
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

Sorry for the delay in responding.  See below.

Trond Myklebust wrote:
> On Tue, 2007-05-29 at 10:10 -0400, Chuck Lever wrote:
>> Trond Myklebust wrote:
>>> On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
>>>> Follow kernel coding conventions.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>>  fs/nfs/nfs4_fs.h  |    5 ++++
>>>>  fs/nfs/nfs4proc.c |   70 ++++++++++++++++++++++++++++--------------=
-----------
>>>>  2 files changed, 42 insertions(+), 33 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>>> index cf3a17e..1a526c4 100644
>>>> --- a/fs/nfs/nfs4_fs.h
>>>> +++ b/fs/nfs/nfs4_fs.h
>>>> @@ -145,6 +145,11 @@ struct nfs4_exception {
>>>>  	int retry;
>>>>  };
>>>> =20
>>>> +#define DECLARE_NFS4_EXCEPTION(name)				\
>>>> +	struct nfs4_exception name =3D {				\
>>>> +		.timeout	=3D 0,				\
>>>> +	}
>>> Why would we want this? The existing code uses bog standard C99
>>> initialisers. There is no need to explicitly set .timeout to zero.
>> Using
>>
>>    struct nfs4_exception name =3D { };
>>
>> causes compiler complaints.  One correct way to fix this is to set at=20
>> least one field in the structure, and setting that field to zero clear=
s=20
>> the other one by default.
>=20
> I can't find anything in Harbison & Steele stating that name =3D {} is
> illegal. All they say is that "if there are fewer initializers than
> there are structure components, the remaining components are initialize=
d
> to their default initial values.".

The exact compiler warning is this:

/home/cel/src/linux/main/fs/nfs/nfs4proc.c: In function=20
=91nfs4_do_open_reclaim=92:
/home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: missing initiali=
zer
/home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: (near=20
initialization for =91exception.timeout=92)

> Anyhow, if you really do have to set one component, then a much less
> verbose form would be to write "name =3D {0}" There is no need for the
> macro.

Yes, that is less verbose.  But it doesn't eliminate the warning, which=20
becomes this:

/home/cel/src/linux/main/fs/nfs/nfs4proc.c: In function=20
=91nfs4_do_open_reclaim=92:
/home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: missing initiali=
zer
/home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: (near=20
initialization for =91exception.retry=92)

So a complete structure initializer is necessary to eliminate both warnin=
gs.

>>>>  struct nfs4_state_recovery_ops {
>>>>  	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *=
);
>>>>  	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 648e0ac..b220c09 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -493,7 +493,7 @@ static int _nfs4_do_open_reclaim(struct nfs4_sta=
te_owner *sp, struct nfs4_state
>>>>  static int nfs4_do_open_reclaim(struct nfs4_state_owner *sp, struct=
 nfs4_state *state, struct dentry *dentry)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(state->inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D _nfs4_do_open_reclaim(sp, state, dentry);
>>>> @@ -538,8 +538,8 @@ static int _nfs4_open_delegation_recall(struct d=
entry *dentry, struct nfs4_state
>>>> =20
>>>>  int nfs4_open_delegation_recall(struct dentry *dentry, struct nfs4_=
state *state)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>>  	struct nfs_server *server =3D NFS_SERVER(dentry->d_inode);
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D _nfs4_open_delegation_recall(dentry, state);
>>>> @@ -843,7 +843,7 @@ static int _nfs4_open_expired(struct nfs4_state_=
owner *sp, struct nfs4_state *st
>>>>  static inline int nfs4_do_open_expired(struct nfs4_state_owner *sp,=
 struct nfs4_state *state, struct dentry *dentry)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(dentry->d_inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -938,8 +938,8 @@ out_put_state_owner:
>>>> =20
>>>>  static struct nfs4_state *nfs4_open_delegated(struct inode *inode, =
int flags, struct rpc_cred *cred)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>>  	struct nfs4_state *res =3D ERR_PTR(-EIO);
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -1008,7 +1008,7 @@ out_err:
>>>> =20
>>>>  static struct nfs4_state *nfs4_do_open(struct inode *dir, struct de=
ntry *dentry, int flags, struct iattr *sattr, struct rpc_cred *cred)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	struct nfs4_state *res;
>>>>  	int status;
>>>> =20
>>>> @@ -1090,7 +1090,7 @@ static int nfs4_do_setattr(struct inode *inode=
, struct nfs_fattr *fattr,
>>>>                  struct iattr *sattr, struct nfs4_state *state)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -1330,7 +1330,9 @@ out_drop:
>>>> =20
>>>>  static int _nfs4_server_capabilities(struct nfs_server *server, str=
uct nfs_fh *fhandle)
>>>>  {
>>>> -	struct nfs4_server_caps_res res =3D {};
>>>> +	struct nfs4_server_caps_res res =3D {
>>>> +		.acl_bitmask =3D 0,
>>>> +	};
>>>>  	struct rpc_message msg =3D {
>>>>  		.rpc_proc =3D &nfs4_procedures[NFSPROC4_CLNT_SERVER_CAPS],
>>>>  		.rpc_argp =3D fhandle,
>>>> @@ -1354,7 +1356,7 @@ static int _nfs4_server_capabilities(struct nf=
s_server *server, struct nfs_fh *f
>>>> =20
>>>>  int nfs4_server_capabilities(struct nfs_server *server, struct nfs_=
fh *fhandle)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -1387,7 +1389,7 @@ static int _nfs4_lookup_root(struct nfs_server=
 *server, struct nfs_fh *fhandle,
>>>>  static int nfs4_lookup_root(struct nfs_server *server, struct nfs_f=
h *fhandle,
>>>>  		struct nfs_fsinfo *info)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -1476,7 +1478,7 @@ static int _nfs4_proc_getattr(struct nfs_serve=
r *server, struct nfs_fh *fhandle,
>>>> =20
>>>>  static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_=
fh *fhandle, struct nfs_fattr *fattr)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -1568,7 +1570,7 @@ static int nfs4_proc_lookupfh(struct nfs_serve=
r *server, struct nfs_fh *dirfh,
>>>>  			      struct qstr *name, struct nfs_fh *fhandle,
>>>>  			      struct nfs_fattr *fattr)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -1612,7 +1614,7 @@ static int _nfs4_proc_lookup(struct inode *dir=
, struct qstr *name,
>>>> =20
>>>>  static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, s=
truct nfs_fh *fhandle, struct nfs_fattr *fattr)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dir),
>>>> @@ -1627,7 +1629,9 @@ static int _nfs4_proc_access(struct inode *ino=
de, struct nfs_access_entry *entry
>>>>  	struct nfs4_accessargs args =3D {
>>>>  		.fh =3D NFS_FH(inode),
>>>>  	};
>>>> -	struct nfs4_accessres res =3D { 0 };
>>>> +	struct nfs4_accessres res =3D {
>>>> +		.access =3D 0,
>>>> +	};
>>>>  	struct rpc_message msg =3D {
>>>>  		.rpc_proc =3D &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
>>>>  		.rpc_argp =3D &args,
>>>> @@ -1668,7 +1672,7 @@ static int _nfs4_proc_access(struct inode *ino=
de, struct nfs_access_entry *entry
>>>> =20
>>>>  static int nfs4_proc_access(struct inode *inode, struct nfs_access_=
entry *entry)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(inode),
>>>> @@ -1723,7 +1727,7 @@ static int _nfs4_proc_readlink(struct inode *i=
node, struct page *page,
>>>>  static int nfs4_proc_readlink(struct inode *inode, struct page *pag=
e,
>>>>  		unsigned int pgbase, unsigned int pglen)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(inode),
>>>> @@ -1813,7 +1817,7 @@ static int _nfs4_proc_remove(struct inode *dir=
, struct qstr *name)
>>>> =20
>>>>  static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dir),
>>>> @@ -1907,7 +1911,7 @@ static int _nfs4_proc_rename(struct inode *old=
_dir, struct qstr *old_name,
>>>>  static int nfs4_proc_rename(struct inode *old_dir, struct qstr *old=
_name,
>>>>  		struct inode *new_dir, struct qstr *new_name)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(old_dir),
>>>> @@ -1954,7 +1958,7 @@ static int _nfs4_proc_link(struct inode *inode=
, struct inode *dir, struct qstr *
>>>> =20
>>>>  static int nfs4_proc_link(struct inode *inode, struct inode *dir, s=
truct qstr *name)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(inode),
>>>> @@ -2011,7 +2015,7 @@ static int _nfs4_proc_symlink(struct inode *di=
r, struct dentry *dentry,
>>>>  static int nfs4_proc_symlink(struct inode *dir, struct dentry *dent=
ry,
>>>>  		struct page *page, unsigned int len, struct iattr *sattr)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dir),
>>>> @@ -2064,7 +2068,7 @@ static int _nfs4_proc_mkdir(struct inode *dir,=
 struct dentry *dentry,
>>>>  static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry=
,
>>>>  		struct iattr *sattr)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dir),
>>>> @@ -2110,7 +2114,7 @@ static int _nfs4_proc_readdir(struct dentry *d=
entry, struct rpc_cred *cred,
>>>>  static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred=
 *cred,
>>>>                    u64 cookie, struct page *page, unsigned int count=
, int plus)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dentry->d_inode),
>>>> @@ -2180,7 +2184,7 @@ static int _nfs4_proc_mknod(struct inode *dir,=
 struct dentry *dentry,
>>>>  static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry=
,
>>>>  		struct iattr *sattr, dev_t rdev)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(dir),
>>>> @@ -2209,7 +2213,7 @@ static int _nfs4_proc_statfs(struct nfs_server=
 *server, struct nfs_fh *fhandle,
>>>> =20
>>>>  static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_f=
h *fhandle, struct nfs_fsstat *fsstat)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(server,
>>>> @@ -2237,7 +2241,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *=
server, struct nfs_fh *fhandle,
>>>> =20
>>>>  static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh =
*fhandle, struct nfs_fsinfo *fsinfo)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -2280,7 +2284,7 @@ static int _nfs4_proc_pathconf(struct nfs_serv=
er *server, struct nfs_fh *fhandle
>>>>  static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs=
_fh *fhandle,
>>>>  		struct nfs_pathconf *pathconf)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -2599,7 +2603,7 @@ out_free:
>>>> =20
>>>>  static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf=
, size_t buflen)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	ssize_t ret;
>>>>  	do {
>>>>  		ret =3D __nfs4_get_acl_uncached(inode, buf, buflen);
>>>> @@ -2653,7 +2657,7 @@ static int __nfs4_proc_set_acl(struct inode *i=
node, const void *buf, size_t bufl
>>>> =20
>>>>  static int nfs4_proc_set_acl(struct inode *inode, const void *buf, =
size_t buflen)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D nfs4_handle_exception(NFS_SERVER(inode),
>>>> @@ -2950,7 +2954,7 @@ static int _nfs4_proc_delegreturn(struct inode=
 *inode, struct rpc_cred *cred, co
>>>>  int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cre=
d, const nfs4_stateid *stateid)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>>  	do {
>>>>  		err =3D _nfs4_proc_delegreturn(inode, cred, stateid);
>>>> @@ -3025,7 +3029,7 @@ out:
>>>> =20
>>>>  static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struc=
t file_lock *request)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -3354,7 +3358,7 @@ static int _nfs4_do_setlk(struct nfs4_state *s=
tate, int cmd, struct file_lock *f
>>>>  static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_=
lock *request)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(state->inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -3372,7 +3376,7 @@ static int nfs4_lock_reclaim(struct nfs4_state=
 *state, struct file_lock *request
>>>>  static int nfs4_lock_expired(struct nfs4_state *state, struct file_=
lock *request)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(state->inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	err =3D nfs4_set_lock_state(state, request);
>>>> @@ -3433,7 +3437,7 @@ out:
>>>> =20
>>>>  static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struc=
t file_lock *request)
>>>>  {
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	do {
>>>> @@ -3483,7 +3487,7 @@ nfs4_proc_lock(struct file *filp, int cmd, str=
uct file_lock *request)
>>>>  int nfs4_lock_delegation_recall(struct nfs4_state *state, struct fi=
le_lock *fl)
>>>>  {
>>>>  	struct nfs_server *server =3D NFS_SERVER(state->inode);
>>>> -	struct nfs4_exception exception =3D { };
>>>> +	DECLARE_NFS4_EXCEPTION(exception);
>>>>  	int err;
>>>> =20
>>>>  	err =3D nfs4_set_lock_state(state, fl);
>>>>
>=20


--------------070900050700050008080500
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
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------070900050700050008080500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070900050700050008080500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070900050700050008080500--
