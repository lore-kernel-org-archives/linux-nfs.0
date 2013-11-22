Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635Ab3KVVjf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Nov 2013 16:39:35 -0500
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Andy Adamson <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <3ABF556D-FA65-4A9E-9880-5AA5ADF80F55@gmail.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
	 <1382454148.9794.72.camel@willson.li.ssimo.org>
	 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
	 <1382458162.9794.85.camel@willson.li.ssimo.org>
	 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
	 <1382462720.9794.131.camel@willson.li.ssimo.org>
	 <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com>
	 <1384980587.17044.49.camel@willson.li.ssimo.org>
	 <528E0C8A.9070608@RedHat.com>
	 <1385147500.3912.68.camel@willson.li.ssimo.org>
	 <3ABF556D-FA65-4A9E-9880-5AA5ADF80F55@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Nov 2013 16:39:31 -0500
Message-ID: <1385156371.22025.5.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-22 at 16:28 -0500, Trond Myklebust wrote:
> On Nov 22, 2013, at 14:11, Simo Sorce <simo@redhat.com> wrote:
> 
> > On Thu, 2013-11-21 at 08:37 -0500, Steve Dickson wrote:
> >> 
> >> On 20/11/13 15:49, Simo Sorce wrote:
> >>>> I think Solution 3: [nfslog/nfslogout interfaces invoked from PAM or
> >>>>> other login system facility] is a good way to go.  Note that a PAM
> >>>>> based solution where in the PAM would get us most of the way towards
> >>>>> providing users with a way to login and logout of NFS kerberized
> >>>>> shares.
> >>>>> 
> >>>>> Comments on an NFS PAM that will destroy GSS context for a UID upon
> >>>>> logout?
> >>> I prefer 3 too, let it to the login system (whether PAM based or other)
> >>> to determine when it is time to destroy credentials, that's the only
> >>> component that have a chance of guessing right.
> 
> Really? How do you deal with backgrounded tasks?

for  background tasks you still need to keep your kerberos credentials
around somehow, if you are doing that then the kernel will be able to
get a new session key if needed.
If you instruct your system to destroy everything then background tasks
will fail. In any case it needs to be a user space decision, the kernel
can't guess.

> >>> Of course you could also provide a user utility to force a purge.
> >>> 
> >> +1 for me on this options as well... 
> >> 
> >> But how is it known when somebody logs out? Is that PAM-able as well?
> > 
> > I would say "login process" more than pam, but the basic idea is the
> > same, a user space program that knows when the user is logging out for
> > good and is privileged enough to go an tell the kernel to nuke creds.
> 
> What’s such a process going to use as an indicator that the user is “logging out for good”?

If you do logout from a graphical login manager that's a pretty good
indication I would say. Whether that will work for all use cases is
debatable of course, I am sure cases can be found where that will not
the right option.

On a system where it is too difficult to properly assess automatically
when a user is logged out for good the only option is to disable any
automatism and let the user call a cmdline tool.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

