Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44774 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754649AbeAGXj1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 7 Jan 2018 18:39:27 -0500
From: NeilBrown <neilb@suse.com>
To: Jonathan Corbet <corbet@lwn.net>,
        Matthew Wilcox <willy@infradead.org>
Date: Mon, 08 Jan 2018 10:39:14 +1100
Cc: linux-doc@vger.kernel.org, dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need to sort group_list
In-Reply-To: <20180106110908.0adc1be2@lwn.net>
References: <878te9os81.fsf@notabene.neil.brown.name> <20171211142708.GA23284@bombadil.infradead.org> <20171211151420.18655-1-thiago.becker@gmail.com> <20742.1514904840@warthog.procyon.org.uk> <87wp10dlgk.fsf@notabene.neil.brown.name> <20180102210431.GA20405@bombadil.infradead.org> <20180106110908.0adc1be2@lwn.net>
Message-ID: <87608dck7x.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 06 2018, Jonathan Corbet wrote:

> There is value in using the c:func syntax, as it will generate
> cross-references to the kerneldoc comments for those functions.  In this
> case, it would appear that these comments exist, but nobody has pulled
> them into the docs yet.  I took the liberty of adding :c:func: references
> to this patch on its way into docs-next so that things will Just Work on
> that happy day when somebody adds the function documentation.

Is this the sort of thing that might result in that happy day?
I didn't spend tooo much time on it, in case including the
kernel-doc in credentials.rst like this was the wrong direction.

Thanks,
NeilBrown


=2D-----------------------------8<-------------------------
From: NeilBrown <neilb@suse.com>
Subject: [PATCH] Documentation: include kernel-doc in credentials.rst

=2D kernel-doc from include/linux/cred.h, kernel/cred.c, and
  kernel/group.c is included in credentials.rst.
=2D Various function references in credentials.rst are changed
  to link to this documentation.
=2D Various minor improvements to the documentation.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/security/credentials.rst | 55 ++++++++++++++++++------------=
----
 kernel/groups.c                        | 19 +++++++++++-
 2 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/Documentation/security/credentials.rst b/Documentation/securit=
y/credentials.rst
index 66a2e24939d8..fd1b7d3b2a78 100644
=2D-- a/Documentation/security/credentials.rst
+++ b/Documentation/security/credentials.rst
@@ -296,7 +296,7 @@ for example), it must be considered immutable, barring =
two exceptions:
=20
 To catch accidental credential alteration at compile time, struct task_str=
uct
 has _const_ pointers to its credential sets, as does struct file.  Further=
more,
=2Dcertain functions such as ``get_cred()`` and ``put_cred()`` operate on c=
onst
+certain functions such as :c:func:`get_cred` and :c:func:`put_cred` operat=
e on const
 pointers, thus rendering casts unnecessary, but require to temporarily dit=
ch
 the const qualification to be able to alter the reference count.
=20
@@ -391,8 +391,8 @@ This does all the RCU magic inside of it.  The caller m=
ust call put_cred() on
 the credentials so obtained when they're finished with.
=20
 .. note::
=2D   The result of ``__task_cred()`` should not be passed directly to
=2D   ``get_cred()`` as this may race with ``commit_cred()``.
+   The result of :c:func:`__task_cred()` should not be passed directly to
+   :c:func:`get_cred` as this may race with :c:func:`commit_cred`.
=20
 There are a couple of convenience functions to access bits of another task=
's
 credentials, hiding the RCU magic from the caller::
@@ -406,7 +406,7 @@ If the caller is holding the RCU read lock at the time =
anyway, then::
 	__task_cred(task)->euid
=20
 should be used instead.  Similarly, if multiple aspects of a task's creden=
tials
=2Dneed to be accessed, RCU read lock should be used, ``__task_cred()`` cal=
led,
+need to be accessed, RCU read lock should be used, :c:func:`__task_cred` c=
alled,
 the result stored in a temporary pointer and then the credential aspects c=
alled
 from that before dropping the lock.  This prevents the potentially expensi=
ve
 RCU magic from being invoked multiple times.
@@ -433,11 +433,8 @@ alter those of another task.  This means that it doesn=
't need to use any
 locking to alter its own credentials.
=20
 To alter the current process's credentials, a function should first prepar=
e a
=2Dnew set of credentials by calling::
=2D
=2D	struct cred *prepare_creds(void);
=2D
=2Dthis locks current->cred_replace_mutex and then allocates and constructs=
 a
+new set of credentials by calling :c:func:`prepare_creds`.
+This locks ``current->cred_replace_mutex`` and then allocates and construc=
ts a
 duplicate of the current process's credentials, returning with the mutex s=
till
 held if successful.  It returns NULL if not successful (out of memory).
=20
@@ -453,10 +450,7 @@ still at this point.
=20
=20
 When the credential set is ready, it should be committed to the current pr=
ocess
=2Dby calling::
=2D
=2D	int commit_creds(struct cred *new);
=2D
+by calling :c:func:`commit_creds`.
 This will alter various aspects of the credentials and the process, giving=
 the
 LSM a chance to do likewise, then it will use ``rcu_assign_pointer()`` to
 actually commit the new credentials to ``current->cred``, it will release
@@ -467,20 +461,17 @@ This function is guaranteed to return 0, so that it c=
an be tail-called at the
 end of such functions as ``sys_setresuid()``.
=20
 Note that this function consumes the caller's reference to the new credent=
ials.
=2DThe caller should _not_ call ``put_cred()`` on the new credentials after=
wards.
+The caller should _not_ call :c:func:`put_cred` on the new credentials aft=
erwards.
=20
 Furthermore, once this function has been called on a new set of credential=
s,
 those credentials may _not_ be changed further.
=20
=20
 Should the security checks fail or some other error occur after
=2D``prepare_creds()`` has been called, then the following function should =
be
=2Dinvoked::
=2D
=2D	void abort_creds(struct cred *new);
=2D
+:c:func:`prepare_creds` has been called, then the function
+:c:func:`abort_creds` should be invoked.
 This releases the lock on ``current->cred_replace_mutex`` that
=2D``prepare_creds()`` got and then releases the new credentials.
+:c:func:`prepare_creds` got and then releases the new credentials.
=20
=20
 A typical credentials alteration function would look something like this::
@@ -512,19 +503,20 @@ There are some functions to help manage credentials:
=20
  - ``void put_cred(const struct cred *cred);``
=20
=2D     This releases a reference to the given set of credentials.  If the
+     :c:func:`put_cred` releases a reference to the given set of credentia=
ls.  If the
      reference count reaches zero, the credentials will be scheduled for
      destruction by the RCU system.
=20
  - ``const struct cred *get_cred(const struct cred *cred);``
=20
=2D     This gets a reference on a live set of credentials, returning a poi=
nter to
=2D     that set of credentials.
+     :c:func:`get_cred` gets a reference on a live set of credentials,
+     returning a pointer to that set of credentials.
=20
  - ``struct cred *get_new_cred(struct cred *cred);``
=20
=2D     This gets a reference on a set of credentials that is under constru=
ction
=2D     and is thus still mutable, returning a pointer to that set of crede=
ntials.
+     :c:func:`get_new_cred` gets a reference on a set of credentials
+     that is under construction and is thus still mutable, returning a
+     pointer to that set of credentials.=20
=20
=20
 Open File Credentials
@@ -546,9 +538,20 @@ Overriding the VFS's Use of Credentials
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 Under some circumstances it is desirable to override the credentials used =
by
=2Dthe VFS, and that can be done by calling into such as ``vfs_mkdir()`` wi=
th a
+the VFS, and that can be done by calling into such as :c:func:`vfs_mkdir` =
with a
 different set of credentials.  This is done in the following places:
=20
  * ``sys_faccessat()``.
  * ``do_coredump()``.
  * nfs4recover.c.
+
+List of functions for managing credentials
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+.. kernel-doc:: include/linux/cred.h
+
+.. kernel-doc:: kernel/cred.c
+   :export:
+
+.. kernel-doc:: kernel/groups.c
+   :export:
diff --git a/kernel/groups.c b/kernel/groups.c
index daae2f2dc6d4..dddbb52f9035 100644
=2D-- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -86,6 +86,19 @@ static int gid_cmp(const void *_a, const void *_b)
 	return gid_gt(a, b) - gid_lt(a, b);
 }
=20
+/**
+ * groups_sort - sort supplementary group list numerically
+ * @group_info: The group list
+ *
+ * groups_search() uses a binary search to see if a
+ * given gid is a member of a group list, so the list must be
+ * sorted.  This can be achieved by calling groups_sort().
+ * As a &struct group_info is often shared, and as this function
+ * can temporary permute elements even of a sorted list,
+ * groups_sort() must be called *before* a @struct group_info
+ * is added to a credential, typically using set_groups() or
+ * set_current_groups().
+ */
 void groups_sort(struct group_info *group_info)
 {
 	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
@@ -119,6 +132,10 @@ int groups_search(const struct group_info *group_info,=
 kgid_t grp)
  * set_groups - Change a group subscription in a set of credentials
  * @new: The newly prepared set of credentials to alter
  * @group_info: The group list to install
+ *
+ * The group list must already be sorted (by groups_sort())
+ * and the credential must not be in active use.  To change the
+ * groups list of an active credential, use set_current_groups().
  */
 void set_groups(struct cred *new, struct group_info *group_info)
 {
@@ -134,7 +151,7 @@ EXPORT_SYMBOL(set_groups);
  * @group_info: The group list to impose
  *
  * Validate a group subscription and, if valid, impose it upon current's t=
ask
=2D * security record.
+ * security record.  The group list must already be sorted.
  */
 int set_current_groups(struct group_info *group_info)
 {
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpSr6IACgkQOeye3VZi
gbmayxAAq7hvU6DHcsI1xqOFQtJNzasVzyqkHiyNsHOZ5z/9XT5hWB5mU4pmrKqU
3hFDqkmlYpHUO7Hfi8lHAqlV93ygcNcoK62hfhUjlxAZun22Yq0kHMsUoVwosyzO
VMy0HAHF9S911qb+xeVk196rzPBseoiYOFDUi+Vy+bUVGwhpeo1H2EVtJkQyVvUV
NEw09S++bB7R/6PQxWM3juanlSEdSyGN9DJmPjGDbgy7wG6VbMw+B9EOT3LDhB1Q
ad5srpijrrCA5DPURchrRkae1yp9HtGJR47dzJWsTD02K7ryb27WY462vZUuOkvp
rsSS7iIuxgDjcb/DXgmM9ROZKRBBFnkrF3/VAdpojvZVfCF5U2gJ2qMQ0UH0okOr
02Rrugco9sdmhXgWy+VXEGBs+sZhyOI4fbBZsRr80W9hOV4628juqpffoi4yxawS
PvZE8p6Ive2HSQ6reUzwmsdScXYrrjJf4juh+1/pGE4U/NVq5zB45ptYvR+dr6h6
FFOyO3SSCO/7T6rGsrdKV+tdHMWS6lLXdZQDfIhEhcv+1OqDC/A4xKMGGa266pld
mul0Tdcu4hLhzlXSUFBIRqyRxzlWu1kY6Z/53Aph2y74NcfBMZuEKO2cU2oVLT8r
gc6ATz3Nue3wizrlWi3U8Un4yIV82IQJd883wNydI1jzwHX3UKQ=
=QoX2
-----END PGP SIGNATURE-----
--=-=-=--
