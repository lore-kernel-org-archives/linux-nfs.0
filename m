Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751651AbdCMVKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Mar 2017 17:10:32 -0400
Date: Mon, 13 Mar 2017 17:10:26 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] sm-notify: ending the grace period early
 should be configurable
Message-ID: <20170313211026.tt464mtetgtcwu4m@tonberry.usersys.redhat.com>
References: <1489181959-2905-1-git-send-email-smayhew@redhat.com>
 <20170313201916.GA15183@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170313201916.GA15183@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Mar 2017, J. Bruce Fields wrote:

> On Fri, Mar 10, 2017 at 04:39:19PM -0500, Scott Mayhew wrote:
> > sm-notify's early ending of the grace period when it has no hosts to
> > notify can cause problems in some high availability configurations,
> > which may be running one sm-notify per floating IP address in the
> > cluster.
> 
> So, there may be no hosts associated with this floating IP, but there
> may be with another?

Exactly.  What was happening in my testing was that clients would
receive and respond to a NOTIFY, and would immediately send a LOCK with
reclaim=yes but would get NFSERR_NO_GRACE in return.

BTW I had a cluster with this change running at Connectathon.

-Scott
> 
> > This commit makes that behavior configurable via the
> > nfs.conf (I don't think having a corresponding command line option
> > would be particularly useful, hence none was added).
> 
> And, I see that you're defaulting it to on to match existing behavior.
> 
> Makes sense to me, ACK.--b.
> 
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  nfs.conf                  |  1 +
> >  utils/statd/sm-notify.c   |  6 +++++-
> >  utils/statd/sm-notify.man | 18 ++++++++++++++++++
> >  3 files changed, 24 insertions(+), 1 deletion(-)
> > 
> > diff --git a/nfs.conf b/nfs.conf
> > index 81ece06..690645c 100644
> > --- a/nfs.conf
> > +++ b/nfs.conf
> > @@ -65,6 +65,7 @@
> >  # retry-time=900
> >  # outgoing-port=
> >  # outgoing-addr=
> > +# lift-grace=y
> >  #
> >  #[svcgssd]
> >  # principal=
> > diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> > index 623213e..0c6766f 100644
> > --- a/utils/statd/sm-notify.c
> > +++ b/utils/statd/sm-notify.c
> > @@ -45,6 +45,8 @@
> >  
> >  #define NLM_END_GRACE_FILE	"/proc/fs/lockd/nlm_end_grace"
> >  
> > +int lift_grace = 1;
> > +
> >  struct nsm_host {
> >  	struct nsm_host *	next;
> >  	char *			name;
> > @@ -494,6 +496,7 @@ main(int argc, char **argv)
> >  	opt_max_retry = conf_get_num("sm-notify", "retry-time", opt_max_retry / 60) * 60;
> >  	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
> >  	opt_srcaddr = conf_get_str("sm-notify", "outgoing-addr");
> > +	lift_grace = conf_get_bool("sm-notify", "lift-grace", lift_grace);
> >  	s = conf_get_str("statd", "state-directory-path");
> >  	if (s && !nsm_setup_pathnames(argv[0], s))
> >  		exit(1);
> > @@ -570,7 +573,8 @@ usage:		fprintf(stderr,
> >  	(void)nsm_retire_monitored_hosts();
> >  	if (nsm_load_notify_list(smn_get_host) == 0) {
> >  		xlog(D_GENERAL, "No hosts to notify; exiting");
> > -		nsm_lift_grace_period();
> > +		if (lift_grace)
> > +			nsm_lift_grace_period();
> >  		return 0;
> >  	}
> >  
> > diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
> > index bb7f6e0..cfe1e4b 100644
> > --- a/utils/statd/sm-notify.man
> > +++ b/utils/statd/sm-notify.man
> > @@ -241,6 +241,24 @@ These have the same effect as the command line options
> >  .B v
> >  respectively.
> >  
> > +An additional value recognized in the
> > +.B [sm-notify]
> > +section is
> > +.BR lift-grace .
> > +By default,
> > +.B sm-notify
> > +will lift lockd's grace period early if it has no hosts to notify.
> > +Some high availability configurations will run one
> > +.B sm-notify
> > +per floating IP address.  In these configurations, lifting the
> > +grace period early may prevent clients from reclaiming locks.
> > +.RB "Setting " lift-grace " to " n
> > +will prevent
> > +.B sm-notify
> > +from ending the grace period early.
> > +.B lift-grace
> > +has no corresponding command line option.
> > +
> >  The value recognized in the
> >  .B [statd]
> >  section is
> > -- 
> > 2.7.4
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
