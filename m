Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35578 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206AbbIVFYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2015 01:24:21 -0400
Received: by pacfv12 with SMTP id fv12so140109482pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 22:24:20 -0700 (PDT)
Date: Mon, 21 Sep 2015 22:24:16 -0700
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Frank Filz <ffilzlnx@mindspring.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Use a separate superblock if mount requires a different
 security flavor
Message-ID: <20150922052416.GA128720@mage>
References: <1442429367.24127.6.camel@localhost.localdomain>
 <CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com>
 <08D9E2B0-B4A8-4DF0-9BB7-B19B2D260E97@oracle.com>
 <CAHQdGtTJdVf1UU7H=R-VdZPxT=BAKA04bB-WGbPqR38JkUpwMA@mail.gmail.com>
 <001a01d0f0c7$ca84e6d0$5f8eb470$@mindspring.com>
 <CAHQdGtSB6XwQme2GBsQzfjxZf4qJRPhsWSMf+mWbE5501HVBzw@mail.gmail.com>
 <3E2CC450-BB4D-4F08-957D-EB78FE3665BE@oracle.com>
 <EE6B41C1-F6A4-4EA0-BE83-4FD48EED9E42@oracle.com>
 <CAHQdGtQjXigfEzy=Jse0Fv+33B1m4LD-wEC7fZ3Ys2TPQCoacA@mail.gmail.com>
 <74D754DA-7B3E-4753-8619-87909B3AE40A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <74D754DA-7B3E-4753-8619-87909B3AE40A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 21, 2015 at 06:31:48PM -0700, Chuck Lever wrote:
> 
> > On Sep 21, 2015, at 5:43 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> > On Mon, Sep 21, 2015 at 7:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >>> On Sep 17, 2015, at 11:01 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>> 
> >>> 
> >>> On Sep 16, 2015, at 11:32 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >>> 
> >>>> On Wed, Sep 16, 2015 at 5:36 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> >>>>>> On Wed, Sep 16, 2015 at 4:55 PM, Chuck Lever <chuck.lever@oracle.com>
> >>>>>> wrote:
> >>>>>>> 
> >>>>>>> On Sep 16, 2015, at 4:52 PM, Trond Myklebust
> >>>>>> <trond.myklebust@primarydata.com> wrote:
> >>>>>>> 
> >>>>>>>> On Wed, Sep 16, 2015 at 2:49 PM, Frank Filz <ffilzlnx@mindspring.com>
> >>>>>> wrote:
> >>>>>>>>> If a server has two exports from the same filesystem but with
> >>>>>>>>> different security flavors allowed, when the client mounts first one
> >>>>>>>>> and then the second, the same super block was being used. This
> >>>>>>>>> resulted in the security flavor for the first export being applied
> >>>>>>>>> to access to the second export.
> >>>>>>>>> 
> >>>>>>>>> The fix is simply to check the security flavor of the nfs_server
> >>>>>>>>> temporarily constructed for the second mount within
> >>>>>> nfs_compare_super.
> >>>>>>>>> 
> >>>>>>>>> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> >>>>>>>>> ---
> >>>>>>>>> fs/nfs/super.c | 3 +++
> >>>>>>>>> 1 file changed, 3 insertions(+)
> >>>>>>>>> 
> >>>>>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c index 084af10..44d60f1
> >>>>>>>>> 100644
> >>>>>>>>> --- a/fs/nfs/super.c
> >>>>>>>>> +++ b/fs/nfs/super.c
> >>>>>>>>> @@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct
> >>>>>>>>> super_block *sb, void *data)
> >>>>>>>>>     struct nfs_server *server = sb_mntdata->server, *old =
> >>>>>>>>> NFS_SB(sb);
> >>>>>>>>>     int mntflags = sb_mntdata->mntflags;
> >>>>>>>>> 
> >>>>>>>>> +       if(old->client->cl_auth->au_flavor
> >>>>>>>>> +          != server->client->cl_auth->au_flavor)
> >>>>>>>>> +               return 0;
> >>>>>>>> 
> >>>>>>>> Isn't this check already being performed in
> >>>>>>>> nfs_compare_mount_options()? As far as I can see, the difference is
> >>>>>>>> that you are checking unconditionally, whereas
> >>>>>>>> nfs_compare_mount_options only does so if there was a 'sec=' line
> >>>>>>>> specified in the mount options.
> >>>>>>> 
> >>>>>>> Right. If the user doesn't provide a sec=, the security flavor is
> >>>>>>> autonegotiated. In the case Frank describes, there are two directories
> >>>>>>> shared on the server, each from the same FSID but using distinct
> >>>>>>> security policies.
> >>>>>>> 
> >>>>>>> So the mount options comparison is inadequate if no sec= is specified
> >>>>>>> on the mount command line.
> >>>>>> 
> >>>>>> We don't claim to support autonegotiation of multiple security policies per
> >>>>>> filesystem, in general. We only claim to support one auth flavour per super
> >>>>>> block.
> >>>>>> 
> >>>>>> If I understand you correctly, you are knowingly trying to work around that
> >>>>>> limitation by performing multiple mounts of the same filesystem and force it
> >>>>>> to use multiple super blocks. Why can't you then also specify the 'sec='?
> >>>>> 
> >>>>> I see that point, but why not just make this case work smoothly rather than force the user to go back and specify -o sec on the mount?
> >>>> 
> >>>> The main issue is that it violates the policy that we must try our
> >>>> best not to set up situations where the client has cache consistency
> >>>> issues due to the existence of multiple superblocks that all have page
> >>>> caches for the same file.
> >>> 
> >>> The parts of the physical FS's namespace that are accessible
> >>> by each security flavor are disjoint. Aside from hardlinks, is
> >>> there any possibility for cache aliasing in this scenario?
> >>> 
> >>> 
> >>>>> Actually all that is necessary is SOME difference in mount options (or use -o nosharedcache, which could be used on all the mounts so all can have the same mount options...) and allow security negotiation to work.
> >>>> 
> >>>> I'd expect there to be no problems if the admin specifies -o
> >>>> nosharedcache. Please do let me know if that fails to work.
> >>>> 
> >>>>> An interesting question is if there are any servers out there that don't typically provide different FSID for different portions of the namespace, but also provide a mechanism to specify different security policies for different portions of the namespace?

Yes, this is quite common.


> >>>> 
> >>>> That sort of situation is difficult to manage.
> >>> 
> >>> But appears to be allowed by Solaris, and likely also by Linux
> >>> and Ganesha. I think we are going to have to consider it,
> >>> particularly if there is no prohibition against it in the RFCs.
> >> 
> >> It is certainly possible to document best practices or
> >> add admin UI limits to prevent servers from being
> >> configured this way.
> >> 
> >> Meanwhile, the Linux client does allow mounting such
> >> exports when both mounts specify unique “sec=“. If this
> >> is a dangerous or unsupported scenario, perhaps this
> >> should be disallowed somehow.
> >> 
> >> When security is negotiated, the second mount is not
> >> allowed. It could display an informative error message
> >> when if fails.
> > 
> > My main worry with the patch you proposed is that we're only
> > considering a small part of the problem here, namely what happens on
> > mount.
> > What if the user were to mount '/' instead of the particular path you
> > chose, and then simply walk down to the problematic directory? As far
> > as I can see, that will fail just as badly both with and without this
> > patch. Why would users expect that behaviour to be any different to
> > the new mount behaviour?
> 
> <shrug> Maybe that’s a little different, though I don’t
> have direct experience of how this is supposed to work.
> 
> If the client mounts “/“ with an explicit security flavor
> that does not work with all the server’s shares, then
> that’s clearly an admin choice. The root directories of
> inaccessible shares will simply not allow users to cd
> into them.
> 
> When no “sec=“ is specified when mounting “/“ then is the
> client allowed to renegotiate when crossing into real
> shares, or are the real shares accessed only via the same
> flavor that was negotiated for “/“ ? 

5661 is pretty clear about this:

   Because NFSv4 clients possess the ability to change the security
   mechanisms used, after determining what is allowed, by using SECINFO
   and SECINFO_NONAME, the server SHOULD NOT present a different view of
   the namespace based on the security mechanism being used by a client.


> If it’s the former,
> do we know that works well for any set of possible
> security policies specified on the server’s shares? If
> it’s the latter, is it a surprise when some shares are
> not accessible? Dunno.
> 
> 
> > IOW: what is the full set of expectations would we be setting by
> > applying the patch, and what is the rationale for changing some
> > behaviour, but not all?
> 
> Our testing turned up this inconsistency. I don’t think
> we have a particular favorite outcome here, other than
> safe, consistent behavior.
> 
> Since specifying different “sec=“ works now, Frank and I
> thought it was indeed a supported configuration.
> 
> If it’s not, then let’s fix the Linux client to behave
> consistently and/or fail gracefully. The client (or an
> appropriate man page) should help admins understand
> what might be going wrong.
> 
> 
> > Also, while I know that the Linux client has never supported this
> > behaviour. What do the Solaris and FreeBSD clients do, and what are
> > their limitations?
> 
> I’m told the Solaris client has a similar design as
> Linux, in that it attempts to match one superblock to
> each FSID on the server.
> 
> It tries to behave in a consistent manner by using the
> WRONGSEC errors to flip back and forth between security
> flavors as necessary. The Solaris folks recognize this
> is not a good permanent solution, and have similar
> concerns about whether this is a reasonable scenario
> to try to support with more complex logic on the client.
> 
> I suggested some server changes before. It would be
> useful to know whether sharing more than one directory
> on a server’s physical filesystem using distinct
> security policies is a common usage scenario. If it
> isn’t, then preventing such multi-security mounts on
> the client doesn’t seem onerous.

With Data ONTAP 7-mode, this is very easy to do, especially
with qtrees.

With Data ONTAP C-mode, the norm is to export only at the
root of the filesystem. But note that it can massage the
fsids to make it look like there is only one filesystem. So
you would have to be very careful that such a change did
not break access here.

Also, with ZFS under Solaris, it is not very painful to
create a new "filessytem" per directory, etc. I.e., each
for a pool serving up homedirs, each user can appear to
have their own filesystem and their own share/export.

I don't know how easy this would be with a Linux server.
E.g., in a set-top deployment, you would want to restrict
each homedir to a specific IP. While you wouldn't necessarily
have different security-flavors here, you would have different
export options per directory.

> 
> 
> —
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
