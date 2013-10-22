Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab3JVRZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 13:25:23 -0400
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
In-Reply-To: <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
	 <1382454148.9794.72.camel@willson.li.ssimo.org>
	 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
	 <1382458162.9794.85.camel@willson.li.ssimo.org>
	 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Oct 2013 13:25:20 -0400
Message-ID: <1382462720.9794.131.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 17:00 +0000, Adamson, Andy wrote:
> On Oct 22, 2013, at 12:09 PM, Simo Sorce <simo@redhat.com>
>  wrote:
> 
> > On Tue, 2013-10-22 at 15:32 +0000, Adamson, Andy wrote:
> >> On Oct 22, 2013, at 11:02 AM, Simo Sorce <simo@redhat.com> wrote:
> >> 
> >>> On Tue, 2013-10-22 at 10:22 -0400, andros@netapp.com wrote:
> >>>> From: Andy Adamson <andros@netapp.com>
> >>>> 
> >>>> This is an RFC patchset, which will be used for testing.
> >>>> 
> >>>> This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.
> >>>> 
> >>>> We need to do a lot of testing to ensure that once kdestroy and gss-ctx
> >>>> gss_user_destroy is called, all existing buffered
> >>>> writes using the 'destroyed gss credential + context' are serviced.
> >>>> 
> >>>> Differences from version 1:
> >>>> 
> >>>> - moved from nfstgt_login and nfstgt_logout to gsskeyd.
> >>>> - gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
> >>>> key on kdestroy.
> >>>> 
> >>>> gsskeyd will need to act differently for different krb5 credential caches.
> >>> 
> >>> Why ?
> >> 
> >> Just need different parsing to know which directory to poll. 
> >>> 
> >>>> For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
> >>>> while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.
> >>> 
> >>> This is incorrect, Fedora 19 use DIR type ccaches, so you should
> >>> reference a cache withing the dir type, which will notmally be something
> >>> like: DIR:/run/user/<uidnumber>/krb5cc for the whole collection or
> >>> DIR::/run/user/<uidnumber>/krb5cc/txtXXXXXX for the sepcific cache.
> >>> 
> >>> However note that due to issues with DIR type caches we are moving to a
> >>> new KEYRING based type of cache in F20, so assuming any specific type of
> >>> cache is a dead start.
> >> 
> >> But I'm not assuming any kind of kerberos credential cache! I just coded to one type for this RFC.
> >> Didn't you see my KEYRING based ccache comment below?
> > 
> > Ah sorry, I had not noticed.
> > 
> >>>> As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
> >>>> configuration file along the lines of the keytools' request-key.conf file to
> >>>> allow both NFS and CIFS (and other filesystems) to install plugin handlers
> >>>> for kinit/kdestroy events.
> >>> 
> >>> Given in many cases (the desirable ones at least) kerberos credentials
> >>> are not inited via kinit, but rather by things like pam_krb5, sssd, or
> >>> directly imported via sshd, I am trying to understand how you are going
> >>> to address the majority of these cases.
> >> 
> >> All of these cases use a kerberos credential cache which if is of type
> >> FILE the gsskeyd can poll inotify and if it is of type KEY: then
> >> gsskeyd adds the gss-ctx key to the Kerberos keyring (that is the
> >> theory :)) so the same code services kinit/pam_krb5
> > 
> > You wouldn't be able to see it if I set a custom ccache file though
> > export KRB5CCNAME=FILE:/random/sir/foofile
> > 
> >>> Should users put gsskeyd in their .profile/.bashrc files or something ?
> >>> 
> >>>> Else, we could have gssd be the process to poll inotify (given
> >>>> that it already polls rpc_pipefs) and then just have it fork off the
> >>>> subprocess if and when it sees an interesting event.
> >>> 
> >>> What is an 'interesting' event ?
> >> 
> >> TGT (used for NFS TGS) creation/destruction
> > 
> > Shouldn't you care for the specific NFS ticket only ?
> > Although kdestroy is quite blunt, in theory users can simply destroy the
> > specific NFS ticket and keep their TGT.
> 
> AFAICS MIT kdestroy does not let you specifiy which credentials to
> destroy. It simply destroys the whole specified ccache, TGT and all.
> 
> I think Heimdal kdestroy lets you specify...
> 
> WRT NFS: As long as the TGT has not expired, the kernel will upcall
> and GSSD will get a new TGS.  So, the kernel gss_context lifetime ==
> TGT lifetime.
> 
> The solution with the current MIT kdestroy is to have a NFS-only
> kerberos credentail cache - with it's own TGT and only NFS TGS's.

There isn't just kdestroy, applications can use libkrb5 to manipulate
the ccache if needed. I am just pointing out that there are many ways
ccaches are manipulated in real life.

I think it is valuable to be able to invalidate the credentials in the
kernel when the user really wants it, I just think that guessing when
the user/admin wants you to drop the creds based on ccaches interactions
is probably not going to work very well.

So the way I see it you probably want to keep the tracking in whatever
tool you want to use to experiment (say gsskeyd) and only provide a
downcall to the kernel that will tell it: destroy any cache for 'uid
number (optionally pass in a session id too ?)'.

This way you can replace the logic of how to keep track of what is going
on completely in user space, where it can easily be adjusted and adapted
as experience is gained.

IE: track it completely in userspace for now and only provide a syscall
to kill creds per UID, no tracking on the kernel side.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

