Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54254 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037Ab3KMDqn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 22:46:43 -0500
Date: Tue, 12 Nov 2013 22:46:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131113034636.GA32628@fieldses.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
 <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
 <52811CBB.3070204@RedHat.com>
 <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
 <5281290B.6000201@RedHat.com>
 <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
 <20131112161135.25a487da@notabene.brown>
 <F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
 <20131112161634.GC15060@fieldses.org>
 <20131113112346.3f5f3bd0@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20131113112346.3f5f3bd0@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 11:23:46AM +1100, NeilBrown wrote:
> On Tue, 12 Nov 2013 11:16:34 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Nov 12, 2013 at 05:29:46AM +0000, Myklebust, Trond wrote:
> > > 
> > > On Nov 12, 2013, at 0:11, NeilBrown <neilb@suse.de> wrote:
> > > 
> > > > On Mon, 11 Nov 2013 15:33:14 -0500 Chuck Lever <chuck.lever@oracle.com> wrote:
> > > > 
> > > >> 
> > > >> On Nov 11, 2013, at 1:59 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > > >> 
> > > >>> On 11/11/13 13:30, Chuck Lever wrote:
> > > >>>> 
> > > >>>> On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > > >>>> 
> > > >>>>> 
> > > >>>>> 
> > > >>>>> On 09/11/13 18:12, Myklebust, Trond wrote:
> > > >>>>>> One alternative to the above scheme, which I believe that I’ve 
> > > >>>>>> suggested before, is to have a permanent entry in rpc_pipefs 
> > > >>>>>> that rpc.gssd can open and that the kernel can use to detect 
> > > >>>>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
> > > >>>>>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
> > > >>>>>> versions of rpc.gssd will try to open for read anything of the form 
> > > >>>>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
> > > >>>>> 
> > > >>>>> After further review I am going going have to disagree with you on this.
> > > >>>>> Since all the context is cached on the initial mount the kernel
> > > >>>>> should be using the call_usermodehelper() to call up to rpc.gssd 
> > > >>>>> to get the context, which means we could put this upcall noise 
> > > >>>>> to bed... forever! :-)
> > > >>>> 
> > > >>>> Ask Al Viro for his comments on whether the kernel should start 
> > > >>>> gssd (either a daemon or a script).  Hint: wear your kevlar underpants.
> > > >>> I was thinking gssd would become a the gssd-cmd command... Al does not
> > > >>> like the call_usermodehelper() interface?
> > > >> 
> > > >> He doesn't have a problem with call_usermodehelper() in general.  However, the kernel cannot guarantee security if it has to run a fixed command line.  Go ask him to explain.
> > > >> 
> > > >> 
> > > >>> 
> > > >>>> 
> > > >>>> Have you tried Trond's approach yet?
> > > >>> Looking into it... But nothing is trivial in that code... 
> > > >>> 
> > > >>>> 
> > > >>>>> I realize this is not going happen overnight, so I would still
> > > >>>>> like to propose my  nfs4_secure_mounts bool patch as bridge
> > > >>>>> to the new call_usermodehelper()  since its the cleanest 
> > > >>>>> solution so far... 
> > > >>>>> 
> > > >>>>> Thoughts?
> > > >>>> 
> > > >>>> We have workarounds already that work on every kernel since 3.8.
> > > >>>> 
> > > >>> The one that logs 5 to 20 lines (depending on thins are setup or not)
> > > >>> per mount? That does work in some environments but no all. ;-)
> > > >> 
> > > >> When does running rpc.gssd not work?
> > > > 
> > > > Oohh ooh.. Pick me.  Pick me!! I can answer that one.
> > > > 
> > > > Running rpc.gssd does not work if you are mounting a filesystem using the IP
> > > > address of the server and that IP address doesn't have a matching hostname
> > > > anywhere that can be found:
> > > > 
> > > > In a newly creating minimal kvm install without rpc.gssd running,
> > > >   mount 10.0.2.2:/home /mnt
> > > > 
> > > > sleeps for 15 seconds then succeeds.
> > > > If I start rpc.gssd, then the same command takes forever.
> > > > 
> > > > strace of rpc.gssd shows that it complains about not being able to resolve
> > > > the host name and "ERROR: failed to read service info".  Then it keeps the
> > > > pipes open but never sends any message on them, so the kernel just keeps on
> > > > waiting.
> > > > 
> > > > If I change "fail_keep_client" to "fail_destroy_client", then it closes the
> > > > pipe and we get the 15 second timeout back.
> > > > If I change  NI_NAMEREQD to 0, then the mount completes instantly.  (of course
> > > > that make serious compromise security so it was just for testing).
> > > > (Adding an entry to /etc/hosts also gives instant success).
> > > > 
> > > > I'm hoping that someone who understands this code will suggest something
> > > > clever so I don't have to dig through all of it ;-)
> > > 
> > > rpc.gssd is supposed to do a downcall with a zero-length window and an error message in any situation where it cannot establish a GSS context. Normally, I’d expect an EACCES for the above scenario.
> > > 
> > > IOW: that’s a blatant rpc.gssd bug. One that will also affect you when you're doing NFSv3 and add ‘sec=krb5’ to the mount options.
> > 
> > Also why is gssd trying to do a DNS lookup in this case?  This sounds
> > similar to what f9f5450f8f94 "Avoid DNS reverse resolution for server
> > names (take 3)" was trying to fix?
> 
> It is quite possible that I misunderstand something.  But this is my
> understanding.
> 
> 1/ "mount" allows you to use either an IP address or a host name to mount a
>    filesystem.
> 2/ gss requires a hostname to identify the server and find it's key (IP not
>    sufficient).
> 3/ If you use a host name to mount a filesystem, then that exact same host
>    name should be used by gssd to identify the server and its key.
>    The above mentioned patch was trying to enforce this.  The idea was to
>    collect the name given to the 'mount', see if it looked like an IP address
>    or a Server name.  If the later, just use it.  If the former, do a reverse
>    lookup because an IP address is no use by itself for gss.
>    Previously it would always do a reverse DNS lookup from the IP address
>    that was determined from the server-name-or-IP-address.
>    Unfortunately this patch was broken - got the test backwards.
>    A follow-up patch fixed the test: c93e8d8eeafec3e32
> 
> 4/ So the above patch was not intended to address the case of mount-by-IP
>    address at all - and this is the case that is causing me problems.

OK, but it still seems dumb to even attempt the reverse lookup: the
lookup probably isn't secure, and the mount commandline should have a
name that we can match to a krb5 principal without needing any other
lookups.

So I'd think reasonable behavior in this case would be to just try the
IP address on the chance there's actually an nfs/x.y.z.w@REALM
principal.  (Or just fail outright if kerberos doesn't allow principals
that look like that.)

--b.
