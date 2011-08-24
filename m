Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46233 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab1HXXi0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 19:38:26 -0400
Date: Thu, 25 Aug 2011 09:38:16 +1000
From: NeilBrown <neilb@suse.de>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: PATCH/RFC: remove state from struct nfs4_state
Message-ID: <20110825093816.6e97db62@notabene.brown>
In-Reply-To: <4E55869B.9010402@panasas.com>
References: <20110825084601.4d8fcdee@notabene.brown>
	<4E55869B.9010402@panasas.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 24 Aug 2011 16:17:47 -0700 Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 08/24/2011 03:46 PM, NeilBrown wrote:
> > 
> <snip>
> > diff --git a/include/linux/configfs.h b/include/linux/configfs.h
> > index 3081c58..9723858 100644
> > --- a/include/linux/configfs.h
> > +++ b/include/linux/configfs.h
> > @@ -15,8 +15,8 @@
> >   *
> >   * You should have received a copy of the GNU General Public
> >   * License along with this program; if not, write to the
> > - * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
> > - * Boston, MA 021110-1307, USA.
> > + * Free Software Foundation, Inc.,
> > + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
> 
> You did not mean to add all these changes in this particular
> patch, did you?

Oops.... I thought it was a clean tree that I was working with.  Sorry.

> 
> If you are at fixing this (snail mail) address. Can't you just
> remove the darn thing, that no one ever care about. I thing
> you don't need any address. But the most it should just be an
> email. Please don't let us slave every time FSF changes the rent
> (As your patch said about something else this address is set but
>  is never used. Proof of - It was wrong for so many years and no
>  one was hurt ;-) )
:-)

It is certainly wrong having a wrong address.  We should either fix it or
remove it.  The GPL under which the source is released seems to suggest that
it should be fixed.  But that isn't really a topic for this email.

This is the only part of the patch that I meant to send.

Thanks,
NeilBrown


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1ec1a85..36639a0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -211,7 +211,6 @@ struct nfs4_state {
 struct nfs4_exception {
 	long timeout;
 	int retry;
-	struct nfs4_state *state;
 };
 
 struct nfs4_state_recovery_ops {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..8c99ee4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -257,7 +257,6 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_state *state = exception->state;
 	int ret = errorcode;
 
 	exception->retry = 0;
@@ -267,13 +266,8 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OPENMODE:
-			if (state == NULL)
-				break;
-			nfs4_schedule_stateid_recovery(server, state);
-			goto wait_on_recovery;
+			break;
 		case -NFS4ERR_EXPIRED:
-			if (state != NULL)
-				nfs4_schedule_stateid_recovery(server, state);
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
