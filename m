Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755989AbaCLBGT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 21:06:19 -0400
Date: Tue, 11 Mar 2014 21:06:11 -0400
From: Jeffrey Layton <jlayton@redhat.com>
To: Eric Paris <eparis@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Schumaker Anna <Anna.Schumaker@netapp.com>,
        David Quigley <dpquigl@davequigley.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH] nfs: Don't assume we have a security structure
Message-ID: <20140311210611.0e82e3cf@ipyr.poochiereds.net>
In-Reply-To: <1394584698.10287.0.camel@localhost>
References: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com>
	<29D9CA49-A493-471B-932B-959AFF96C729@primarydata.com>
	<EEEA2B4E-BE0F-40C0-91C3-98E2E7E8BB35@primarydata.com>
	<1394584698.10287.0.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Mar 2014 20:38:18 -0400
Eric Paris <eparis@redhat.com> wrote:

> On Tue, 2014-03-11 at 18:00 -0400, Trond Myklebust wrote:
> > On Mar 11, 2014, at 17:27, Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> > 
> > > 
> > > On Mar 11, 2014, at 17:11, Anna Schumaker
> > > <Anna.Schumaker@netapp.com> wrote:
> > > 
> > >> If the i_security field isn't set then
> > >> security_dentry_init_security() won't initialize some of the
> > >> values used by the security label.  This causes my client to hit
> > >> a BUG_ON() while encoding a label of size -2128927414.
> > >> 
> > >> I hit this bug while testing on a client without SELinux
> > >> installed.
> > >> 
> > >> Signed-off-by: Anna Schumaker <anna.schumaker@netapp.com>
> > >> ---
> > >> fs/nfs/nfs4proc.c | 3 +++
> > >> 1 file changed, 3 insertions(+)
> > >> 
> > >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > >> index b8cd560..994ccc2 100644
> > >> --- a/fs/nfs/nfs4proc.c
> > >> +++ b/fs/nfs/nfs4proc.c
> > >> @@ -105,6 +105,9 @@ nfs4_label_init_security(struct inode *dir,
> > >> struct dentry *dentry, if (nfs_server_capable(dir,
> > >> NFS_CAP_SECURITY_LABEL) == 0) return NULL;
> > >> 
> > >> +	if (!dir->i_security)
> > >> +		return NULL;
> > >> +
> > >> 	err = security_dentry_init_security(dentry,
> > >> sattr->ia_mode, &dentry->d_name, (void **)&label->label,
> > >> &label->len); if (err == 0)
> > > 
> > > Hi Anna,
> > > 
> > > This looks like a check that needs to be done by
> > > selinux_dentry_init_security() itself. The dir->i_security field
> > > is not something that NFS knows about. David, what needs to
> > > happen there when dentry->d_parent->i_security (a.k.a. dsec) is
> > > NULL?
> > > 
> > 
> > Oh, wait. I missed the bit about ‘without SELinux installed’. So
> > the problem here is that you have a NFS client that does not have
> > SELinux set up, but running against a server that is advertising
> > NFSv4.2 with labeled NFS. Is that correct?
> > 
> > It looks to me as if cap_dentry_init_security() will indeed trigger
> > this behaviour since it returns ‘0’ without doing anything to the
> > label. As far as I can see, the right thing to do there is to
> > return -EOPNOTSUPP, no?
> 
> I feel like Jeff Layton was looking at the same thing, and came to the
> same conclusion...
> 
> Jeff?
> 

I posted a patch for this last week and James has merged it:

    [PATCH] security: have cap_dentry_init_security return error

I didn't note it in the patch description but it fixes 4.2 when SELinux
is compiled in but disabled.

-- 
Jeff Layton <jlayton@redhat.com>
