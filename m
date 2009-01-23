From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Fri, 23 Jan 2009 13:09:59 -0500
Message-ID: <20090123180959.GA32186@fieldses.org>
References: <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> <497757D1.7090908@RedHat.com> <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com> <49777988.6010401@RedHat.com> <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com> <4977A385.8000406@melbourne.sgi.com> <20090121225619.GI4295@fieldses.org> <497897F5.9030005@RedHat.com> <20090122164503.GC13129@fieldses.org> <4978F91C.4090208@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35569 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbZAWSJ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 13:09:59 -0500
In-Reply-To: <4978F91C.4090208-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 23, 2009 at 09:54:20AM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > On Thu, Jan 22, 2009 at 10:59:49AM -0500, Steve Dickson wrote:
> >   
> >> J. Bruce Fields wrote:
> >>     
> >>
> >> Interesting.... Store something like a reason code (similar to what they have
> >> in he Kerberos)
> >>     
> >
> > Maybe.
> >
> >   
> >> in somewhere in the proc file system? 
> >>     
> >
> > But then I don't know how you'd associate it with a particular mount
> > attempt.
> >
> >
> >   
> You could do something truly awful like add a new code in the unused
> bits of the errno value returned from mount.  It would confuse an
> unmodified userspace, but reporting "Unknown Error" isn't much less
> useful than "I/O Error".

There must be cases where the existing error gives us some information,
but not as much as we'd like, so the "Unknown Error" could be a step
backwards for unmodified userspace.  An extra mount option (normally
hidden from the user) could be used to tell the kernel that the
application doing the mount was capable of handling the new error codes.
Ugh.

--b.
