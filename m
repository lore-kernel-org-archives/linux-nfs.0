From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/5] knfsd: Replace lock_kernel with a mutex for nfsd
 thread startup/shutdown locking.
Date: Fri, 13 Jun 2008 16:12:39 +1000
Message-ID: <18514.4055.390876.939107@notabene.brown>
References: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
	<1213101639-26423-2-git-send-email-jlayton@redhat.com>
	<18512.39490.36187.783761@notabene.brown>
	<20080612083713.30282035@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41134 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbYFMGNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 02:13:22 -0400
In-Reply-To: message from Jeff Layton on Thursday June 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday June 12, jlayton@redhat.com wrote:
> 
> >  static int killsig;	/* signal that was used to kill last nfsd */
> > @@ -275,7 +277,7 @@ static int nfsd_init_socks(int port)
> >  					SVC_SOCK_DEFAULTS);
> >  		if (error < 0)
> >  			lockd_down();
> > -}
> > +	}
> >  	if (error < 0)
> >  		return error;
> >  	return 0;
> 
> This looks correct already in Bruce's tree. Am I missing something?

Only if you are assuming that I will make sense....
I have no idea where that came from now that I go looking for it...

Enjoy,
NeilBrown
