Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab3EUSwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 14:52:04 -0400
Date: Tue, 21 May 2013 14:52:03 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Don't give out read delegations on exclusive
 creates
Message-ID: <20130521185203.GB12114@fieldses.org>
References: <1368643909-8059-1-git-send-email-steved@redhat.com>
 <519BC044.8000808@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <519BC044.8000808@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 21, 2013 at 02:43:16PM -0400, Steve Dickson wrote:
> Hey Bruce,
> 
> Ping... ;-) I just pull from your for-3.11-incoming branch
> and notice it was not there... 

Whoops, this had gotten buried in my inbox somehow.  I'll take a look,
thanks for the reminder.

--b.

> 
> This  really does help with  exclusive creates 
> not being delayed... So you might want to consider it... 
> 
> steved.
> 
> On 15/05/13 14:51, Steve Dickson wrote:
> > When an exclusive create is done with the mode bits
> > set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this
> > causes a OPEN op followed by a SETATTR op. When a
> > read delegation is given in the OPEN, it causes
> > the SETATTR to delay with EAGAIN until the
> > delegation is recalled.
> > 
> > This patch caused exclusive creates to give out
> > a write delegation (which turn into no delegation)
> > which allows the SETATTR seamlessly succeed.
> > 
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 316ec84..6b45d0e 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3035,8 +3035,16 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
> >  				goto out;
> >  			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
> >  				flag = NFS4_OPEN_DELEGATE_WRITE;
> > -			else
> > -				flag = NFS4_OPEN_DELEGATE_READ;
> > +			else {
> > +				switch(open->op_createmode) {
> > +				case NFS4_CREATE_EXCLUSIVE:
> > +				case NFS4_CREATE_EXCLUSIVE4_1:
> > +					flag = NFS4_OPEN_DELEGATE_WRITE;
> > +					break;
> > +				default:
> > +					flag = NFS4_OPEN_DELEGATE_READ;
> > +				}
> > +			}
> >  			break;
> >  		default:
> >  			goto out;
> > 
