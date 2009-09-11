From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] idmapd: rearm event handler after error in nfsdcb()
Date: Fri, 11 Sep 2009 11:39:04 -0400
Message-ID: <20090911153904.GG2095@fieldses.org>
References: <1252611727-19078-1-git-send-email-jlayton@redhat.com> <20090910202825.GL14406@fieldses.org> <20090910170024.2853a48e@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbZIKPjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 11:39:01 -0400
In-Reply-To: <20090910170024.2853a48e-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 05:00:24PM -0400, Jeff Layton wrote:
> On Thu, 10 Sep 2009 16:28:25 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Sep 10, 2009 at 03:42:07PM -0400, Jeff Layton wrote:
> > > A couple of years ago, Bruce committed a patch to make knfsd send
> > > unsigned uid's and gid's to idmapd, rather than signed values. Part
> > > of that earlier discussion is here:
> > > 
> > > http://linux-nfs.org/pipermail/nfsv4/2007-December/007321.html
> > > 
> > > While this fixed the immediate problem, it doesn't appear that anything
> > > was ever done to make idmapd continue working when it gets a bogus
> > > upcall.
> > 
> > Thanks for following up on this!
> > 
> > > 
> > > idmapd uses libevent for its main event handling loop. When idmapd gets
> > > an upcall from knfsd it will service the request and then rearm the
> > > event by calling event_add on the event structure again.
> > > 
> > > When it hits an error though, it returns in most cases w/o rearming the
> > > event. That prevents idmapd from servicing any further requests from
> > > knfsd.
> > > 
> > > I've made another change too. If an error is encountered while reading
> > > the channel file, this patch has it close and reopen the file prior to
> > > rearming the event.
> > > 
> > > I've not been able to test this patch directly, but I have tested a
> > > backport of it to earlier idmapd code and verified that it did prevent
> > > idmapd from hanging when it got a badly formatted upcall from knfsd.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  utils/idmapd/idmapd.c |   18 ++++++++++--------
> > >  1 files changed, 10 insertions(+), 8 deletions(-)
> > > 
> > > diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> > > index 65a6a2a..573abaa 100644
> > > --- a/utils/idmapd/idmapd.c
> > > +++ b/utils/idmapd/idmapd.c
> > > @@ -139,6 +139,7 @@ static void nametoidres(struct idmap_msg *);
> > >  
> > >  static int nfsdopen(void);
> > >  static int nfsdopenone(struct idmap_client *);
> > > +static void nfsdreopen_one(struct idmap_client *);
> > >  static void nfsdreopen(void);
> > >  
> > >  size_t  strlcat(char *, const char *, size_t);
> > > @@ -502,7 +503,8 @@ nfsdcb(int fd, short which, void *data)
> > >  		xlog_warn("nfsdcb: read(%s) failed: errno %d (%s)",
> > >  			     ic->ic_path, len?errno:0, 
> > >  			     len?strerror(errno):"End of File");
> > > -		goto out;
> > > +		nfsdreopen_one(ic);
> > > +		return;
> > 
> > Why the "return"?  From your description above ("... close and reopen
> > the file prior to rearming the event"), I would have thought you'd want
> > the final event_add() that's done at "out".
> > 
> > --b.
> > 
> 
> Ahh yeah...it's not very clear from the patch, but nfsdreopen_one()
> rearms the event after reopening the file. Doing a return there should
> be correct.

OK, got it!  Patch looks good to me.

--b.

> 
> > >  	}
> > >  
> > >  	/* Get rid of newline and terminate buffer*/
> > > @@ -514,11 +516,11 @@ nfsdcb(int fd, short which, void *data)
> > >  	/* Authentication name -- ignored for now*/
> > >  	if (getfield(&bp, authbuf, sizeof(authbuf)) == -1) {
> > >  		xlog_warn("nfsdcb: bad authentication name in upcall\n");
> > > -		return;
> > > +		goto out;
> > >  	}
> > >  	if (getfield(&bp, typebuf, sizeof(typebuf)) == -1) {
> > >  		xlog_warn("nfsdcb: bad type in upcall\n");
> > > -		return;
> > > +		goto out;
> > >  	}
> > >  	if (verbose > 0)
> > >  		xlog_warn("nfsdcb: authbuf=%s authtype=%s",
> > > @@ -532,26 +534,26 @@ nfsdcb(int fd, short which, void *data)
> > >  		im.im_conv = IDMAP_CONV_NAMETOID;
> > >  		if (getfield(&bp, im.im_name, sizeof(im.im_name)) == -1) {
> > >  			xlog_warn("nfsdcb: bad name in upcall\n");
> > > -			return;
> > > +			goto out;
> > >  		}
> > >  		break;
> > >  	case IC_IDNAME:
> > >  		im.im_conv = IDMAP_CONV_IDTONAME;
> > >  		if (getfield(&bp, buf1, sizeof(buf1)) == -1) {
> > >  			xlog_warn("nfsdcb: bad id in upcall\n");
> > > -			return;
> > > +			goto out;
> > >  		}
> > >  		tmp = strtoul(buf1, (char **)NULL, 10);
> > >  		im.im_id = (u_int32_t)tmp;
> > >  		if ((tmp == ULONG_MAX && errno == ERANGE)
> > >  				|| (unsigned long)im.im_id != tmp) {
> > >  			xlog_warn("nfsdcb: id '%s' too big!\n", buf1);
> > > -			return;
> > > +			goto out;
> > >  		}
> > >  		break;
> > >  	default:
> > >  		xlog_warn("nfsdcb: Unknown which type %d", ic->ic_which);
> > > -		return;
> > > +		goto out;
> > >  	}
> > >  
> > >  	imconv(ic, &im);
> > > @@ -612,7 +614,7 @@ nfsdcb(int fd, short which, void *data)
> > >  		break;
> > >  	default:
> > >  		xlog_warn("nfsdcb: Unknown which type %d", ic->ic_which);
> > > -		return;
> > > +		goto out;
> > >  	}
> > >  
> > >  	bsiz = sizeof(buf) - bsiz;
> > > -- 
> > > 1.5.5.6
> > > 
> > > _______________________________________________
> > > NFSv4 mailing list
> > > NFSv4@linux-nfs.org
> > > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
