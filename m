Received: from flow-a5-smtp.messagingengine.com (flow-a5-smtp.messagingengine.com [103.168.172.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A49B023ED5E;
	Tue, 18 Aug 2026 23:30:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787095849; cv=none; b=VuPPPV7J6fo3VEnOG4g4FnUs4hXI3Gr0w+lI8MiHrNMS5Q6Osird2kC1vhvFA04nS8gks0srC1mDEiYFFOUuMAXRABeGXlEXkd/aEjGNbTCFWWMSSXL3jjVuHMCCcVXoFWrVOvw8Pqbt+w4SmI0Ar9BF/ViOp8LFP5S0xryrPtc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787095849; c=relaxed/simple;
	bh=GVVhxRD3meuo/MAG10wUT45u+EL5FhzJQcVOqryj0bA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=T0f+VVInhxmw11/PUCSSPFzEF9wmj9j9H7XIBuNiGGvbuNKVmii6T6dYw59ZYDlESZPw9K/ekSPA++HjTxfnXEmr1ig2S1mv9vU4Opq6r2mODZL2UU8GGsIZPjqFT/FUv/Kq1PBPnr/sgfXFqw7RfDBGvXziN9xCrIDbpwyAZZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bSGGqi1d; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=jIxS5xMv; arc=none smtp.client-ip=103.168.172.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bSGGqi1d";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jIxS5xMv"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.phl.internal (Postfix) with ESMTP id 8E2DB138020D;
	Tue, 18 Aug 2026 19:30:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Tue, 18 Aug 2026 19:30:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787095845; x=1787103045; bh=QVGxJhfZ6TEk5xPfS9fmH4i0uyZKzqFuVYj
	n79ZJLMA=; b=bSGGqi1d1YzWxMIwbKD6cae7CicyksvQARg/ElX8iSN9OJbjEWV
	bVKa5P6xd2USbobt1KyLx77GLPquFLX8xCv2ON68ClInHUPQyjtalsc1KfWAorPr
	EDn9KhHS/OlyGESrjLYMPUOEcbY3EjpVO0zO29nkZ/NeXQ/y1j86iuRBbARWIPJ0
	1jB7hXnqKawz855IbYoS1oKtCdt8wLgc/2vEEtcqzi+wJfAsUQ5flP7KczKn49hg
	rV1FDA1+PvfDQafMctDK33D05YVOCCMPKnij3RlEwncej3FylhodybEA+NcuSeqT
	vsA8TwlIqNxd/sN0kLf2whVmUaPLuQGG8OQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787095845; x=
	1787103045; bh=QVGxJhfZ6TEk5xPfS9fmH4i0uyZKzqFuVYjn79ZJLMA=; b=j
	IxS5xMvR8Cy69iAizxCYgNuNh/QEdBQyHElCzxJWT+7tNlyMk3c+4Uu8cRXaOkFG
	Yg+CqsYhGyckK8OvpiRs2J92w+eB6n2ogT3uc6Y2AD1NF4xFR1Py6MznDg/4cdJn
	DRYD6xqTpjk0mOwH9slgaNWlqJITZ3Ef/A8Ngau/sIczCPv3+xNucscFEYVi8BTE
	SeIdGWEDNTKXEWHYbP7Z12MLc/RLjBhRwRMHQyQKwB89v0RdBwSzYO70jm2PNIJ9
	/WWk1yp6SaZ6DlxPrg0x4a57ur4jnCdU/96shycZyoI1EkgNp+KOe4Na/xhUwfo5
	e3OzfuQOzxhemVJ1+W+3g==
X-ME-Sender: <xms:JOuEavPCBbjPl7TooeLPUq3kIt8LWy3omrY1P_jHDwOE5BphqVbefA>
    <xme:JOuEarru-ozRvrd8YlRtUl8rdY5qYMLv7O_fDyD28VdHQhIR9shO9OOm32O2E2q7B
    w9BTYgdmNni8guz6Tp_V9mdAuI6kFxNh-SRAOM7COyAC3OT>
X-ME-Received: <xmr:JOuEahtyydWMCkdOzGY0WlVvgB0o1a8gJKK3i5FXZh54EV2IhesGdXKdbWIH_ygcAA>
X-ME-Proxy-Cause: dmFkZTFT5KJBkRkhQp/33Eo7Md6x2f3Q1QJ5IcFECHJ5hZQltO7r+Zh/8yPpav2aCH+wbv
    FCVPsPwZOb/bXrZn2/qzudCuLTh7oQ2dYVo7v9lA0kPqE74oiF/TiDT8PhqOY7dUjD0x2J
    gsBE5l9lFkPgbw3vETYsbQajLySc6NViGpPUnSSWCQyAu4qF9BYFo36V1jXswbHi4x1GTj
    cEDmUB36mIVR8rcumE4Bch6kZbV9h7YDSGlFPhEKjcMc0a8Q8WrxPEwwQP/6Ffsy3UOtN4
    vyPb0CenWRSBOAWzw5M9VDOIGmFQGz4njeOSsm2M2otx6Lj/gUcuthwD6OrDhKbdqJgyB5
    VBGW5GXuEa1ItMKliR7U1fR1LUZY3j57Hi4vqdRJ8l2PWexxiO4cKHXaPt0c80XlJBPvf0
    n1FviJsCNG3ylmJ/ZDaccFDZTSxz40GgWUevw8+reicUXAl5/aZgB4Ca02KZhacLy34rGu
    JMPLT/VQOgNRH47lebrP5MsJ1QNTGiNrH3OVbKWfeMBm0DzsIPkDQPYvmUBS02jUMgGTM4
    X9Pg6Mz9uiuXMFjcWIGLD5LagvjP1Z3bwIbDp0RQPeaXa6YGtuWLyZSwwmWzvAWYCC7dHS
    P9cndvCZghTXkNZTHI73j/VXA/d2GeQ946vq969NS+PG61vseCrIg/7+SsmA
X-ME-Proxy: <xmx:JOuEajjNnPd0fXzGsHWOsrIl1ZViOnvhWqAWgGEsZ76gSVAuVLScvw>
    <xmx:JOuEat0NMBJrs3B-lFtqIvLysjRwpIfSgsoYJZ3tybjkgtsuS2Lyvw>
    <xmx:JOuEaj_0iHmspIDQjm6-yDTG0BKj4Ec9agGL2QC4aG82KlTFIE2T3g>
    <xmx:JOuEarOfrO3aWihQQrs2fE47Bb0JTigQlmWMLWbw5H2mCjRD4aC6EA>
    <xmx:JeuEakKT2qT0UUuvKx2FAF5Waq20OyYHvaCPyGRSg-l47xvIHUO6RA9y>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 18 Aug 2026 19:30:38 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Amir Goldstein" <amir73il@gmail.com>
Cc: "Jan Kara" <jack@suse.cz>, "Miklos Szeredi" <miklos@szeredi.hu>,
 "Ian Kent" <raven@themaw.net>, "Chuck Lever" <cel@kernel.org>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
In-reply-to:
 <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-4-neilb@ownmail.net>
  <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
  <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
  <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
  <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
  <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
Date: Wed, 19 Aug 2026 09:30:34 +1000
Message-id: <178709583480.2852630.4575326968116183366@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 17 Aug 2026, Amir Goldstein wrote:
> On Mon, Aug 17, 2026 at 1:03=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> >
> > On Sat 15-08-26 10:28:41, NeilBrown wrote:
> > > On Tue, 11 Aug 2026, NeilBrown wrote:
> > > > On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> > > > > On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
> > > > >
> > > > > > @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsno=
tify_mark *inode_mark, u32 mask,
> > > > > >                 else {
> > > > > >                         *prev =3D dn->dn_next;
> > > > > >                         kmem_cache_free(dnotify_struct_cache, dn);
> > > > > > -                       dnotify_recalc_inode_mask(inode_mark);
> > > > > > +                       need_recalc =3D true;
> > > > > >                 }
> > > > > >         }
> > > > > >
> > > > > > +       if (need_recalc)
> > > > > > +               need_recalc =3D dnotify_recalc_inode_mask(inode_m=
ark);
> > > > > >         spin_unlock(&inode_mark->lock);
> > > > > > +       if (need_recalc)
> > > > > > +               fsnotify_recalc_mask(inode_mark->connector);
> > > > >
> > > > > Is the fsnotify_group_lock() held in this case?   I don't see it.
> > > >
> > > > It isn't held.  Doesn't it need to be...
> > > > It seems to protect marks, so maybe it does.
> > > >
> > > > srcu seems to be used to protect this section, so maybe we can rely on
> > > > that.
> > >
> > > I dug into this some more, and we do rely on srcu, but don't need the
> > > extra code below.
> > > inode_mark->lock doesn't protect inode_mark->connector, so moving the
> > > dereference out of the lock has no effect.
> > > srcu_read_lock is taken before we get the ref to the mark, so the mark
> > > and the connector cannot disappear underneath us.
> > > A race could result in inode_mark->connector reading as NULL, but
> > > fsnotify_recalc_mask() checks for NULL, so there is no risk for harm.
> > >
> > > Thanks for encouraging me to dig into this.
> >
> > Sorry for not replying earlier but I was on vacation. The lifetime rules
> > around marks & connectors are subtle so we have to be really careful and
> > dnotify with its single shot marks is peculiar which makes things even
> > harder. fsnotify_recalc_mask() has a comment about locking in front of it:
> >
> > /*
> >  * Calculate mask of events for a list of marks. The caller must make sure
> >  * connector and connector->obj cannot disappear under us.  Callers achie=
ve
> >  * this by holding a mark->lock or mark->group->mark_mutex for a mark on =
this
> >  * list.
> >  */
> >
> > and you very obviously start violating these rules with your changes. Now=
 I
> > admit I've forgotten all the details why I did it like this so let me
> > reconstruct it :).
> >
> > Connector stays alive as long as there's any mark in its list. Both marks
> > and connectors are protected by the srcu. Mark also has
> > FSNOTIFY_MARK_FLAG_ATTACHED flag which is set iff the connector->obj is
> > pointing to valid inode/mount/... FSNOTIFY_MARK_FLAG_ATTACHED changes only
> > under mark_mutex so that's why mark_mutex is stabilizing the connector (a=
nd
> > also connector->obj). This is what is used by most places calling
> > fsnotify_recalc_mask(). But dnotify needs to mess with notification mark
> > mask from event handling and there we cannot take mark_mutex due to lock
> > ordering constraints. That's where the mark->lock rule comes into play
> > because mark->lock also needs to be acquired to clear
> > FSNOTIFY_MARK_FLAG_ATTACHED. That being said this dnotify use of
> > fsnotify_recalc_mask() still looks somewhat racy because
> > dnotify_handle_event() can get called after FSNOTIFY_MARK_FLAG_ATTACHED is
> > cleared.
> >
> > Anyway if you move fsnotify_recalc_mask() call outside of mark->lock, you
> > seem to make the race with dnotify clearing the mark from
> > fcntl_dirnotify() easier to hit. Now in the notification path the inode
> > itself is guaranteed to stay alive and the rest is protected by the SRCU =
so
> > there's no direct UAF. But fsnotify_recalc_mask() simply isn't prepared f=
or
> > the connector changing under it due to object getting detached and so we
> > could end up doing weird things like NULL ptr derefs or similar stuff.
> >
> > So this call to fsnotify_recalc_mask() from dnotify needs a more careful
> > handling. Which is sad because I doubt anybody still uses dnotify...
>=20
> Maybe this is the way out.
>=20
> dnotify_recalc_inode_mask() can only remove bits from i_fsnotify_mask,
> so it is an optimization.
>=20
> If we just remove fsnotify_recalc_mask() call from
> dnotify_recalc_inode_mask(), then i_fsnotify_mask will be updated when
> dnotify_mask gets removed eventually.

I had thought something along these lines too.  I don't think we need to
drop all of fsnotify_recalc_mask(), only the
fsnotify_conn_set_children_dentry_flags() part that walks the d_children
list.  And that only happens when we add to the mask, not when bits are
cleared.  So maybe the fsnotify_conn_set_children_dentry_flags() simply
never happens in this context so it doesn't need fixing.

I would prefer to make that clear from the code with a patch like the
following.

Note that I'm not (yet) convinced by the locking argument, but maybe we
don't need to pursue it.

Thanks,
NeilBrown

diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 9fb73bafd41d..be66d4142563 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -75,7 +75,7 @@ static void dnotify_recalc_inode_mask(struct fsnotify_mark =
*fsn_mark)
 		return;
 	fsn_mark->mask =3D new_mask;
=20
-	fsnotify_recalc_mask(fsn_mark->connector);
+	fsnotify_recalc_mask_inatomic(fsn_mark->connector);
 }
=20
 /*
diff --git a/fs/notify/mark.c b/fs/notify/mark.c
index b2640d836a71..7ba79828b07d 100644
--- a/fs/notify/mark.c
+++ b/fs/notify/mark.c
@@ -322,7 +322,8 @@ static void fsnotify_conn_set_children_dentry_flags(
  * this by holding a mark->lock or mark->group->mark_mutex for a mark on this
  * list.
  */
-void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
+static void do_fsnotify_recalc_mask(struct fsnotify_mark_connector *conn,
+				    bool in_atomic)
 {
 	bool update_children;
=20
@@ -339,10 +340,20 @@ void fsnotify_recalc_mask(struct fsnotify_mark_connecto=
r *conn)
 	 * When parent stops watching, we clear false positive PARENT_WATCHED
 	 * flags lazily in __fsnotify_parent().
 	 */
-	if (update_children)
+	if (update_children && !WARN_ON(in_atomic))
 		fsnotify_conn_set_children_dentry_flags(conn);
 }
=20
+void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
+{
+	do_fsnotify_recalc_mask(conn, false);
+}
+
+void fsnotify_recalc_mask_inatomic(struct fsnotify_mark_connector *conn)
+{
+	do_fsnotify_recalc_mask(conn, true);
+}
+
 /**
  * fsnotify_modify_mark_mask - set and/or clear flags in a mark's mask
  * @mark: mark to be modified
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backen=
d.h
index 618eed4d6d72..3e0fdd639d18 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -887,6 +887,7 @@ static inline __u32 fsnotify_calc_mask(struct fsnotify_ma=
rk *mark)
 extern __u32 fsnotify_conn_mask(struct fsnotify_mark_connector *conn);
 /* Calculate mask of events for a list of marks */
 extern void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn);
+extern void fsnotify_recalc_mask_inatomic(struct fsnotify_mark_connector *co=
nn);
 extern void fsnotify_init_mark(struct fsnotify_mark *mark,
 			       struct fsnotify_group *group);
 /* Find mark belonging to given group in the list of marks */

