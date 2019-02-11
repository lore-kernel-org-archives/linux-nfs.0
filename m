Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7010C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 05:31:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 745A52146F
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 05:31:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bv5fzIGj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725939AbfBKFbr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 00:31:47 -0500
Received: from mail-qt1-f195.google.com ([209.85.160.195]:33851 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725931AbfBKFbr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 00:31:47 -0500
Received: by mail-qt1-f195.google.com with SMTP id w4so2104053qtc.1;
        Sun, 10 Feb 2019 21:31:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2eAqV5NgnhexfGcARJ2ea7Gxrw5wAa30EEVNV5VbGg8=;
        b=Bv5fzIGj5PLWXrKC1B86X0DWFDa9QRkDbR2B5Pn86BHARDfE2XMZuPoKFKeLRIRbNM
         c4zVRleJ4lN7frNJ69niM3LuJYLlAeyPzP54zoHlxpyZm1leE/WrX/DNfZMQkeu5hFQo
         gpmzC73DkjnDQD7M7gmnUWo+FgNKy7epB4h/CHfsyIkNh92nWsjiVA9PYRgbhVPcB/DK
         VQZpBX3JgKsiucq9poXsRIjgOxIyLe2rhvQoWbd1bMLeb5UWgZ/krPCzf7ZIHHaT2cMs
         sCBLTUhtBWorgiq8AfBpaKtKXxEuR6BKshqPn15l0SRbUKHZuJClz3iDc13oOrxZRuEc
         ol8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2eAqV5NgnhexfGcARJ2ea7Gxrw5wAa30EEVNV5VbGg8=;
        b=WRyqYwHSMR+BcBfJC6wGCYiBFlA0rpzpY7YcZ05vsvbd4RrCJ/YEAcm6/7KDo5WY7J
         6LC5fHdlPFUhjDJI+ULazDlOs3FZ7fdPKak/NHQo6T4AHVZCM2iRe0cNplpuGVRqq7c8
         yPS1lf9c00/KewJY93dnVP0K1dBip11BGDNZthX6kzh4VCrBLHap9j5lkCws2v9WKpr5
         uXVXEneXKNHZF/7/c42fGb8mfV0aP0Z9H6g0YL/x8A/f8bhiv9ZKw8fEnp4H9iqUBHSN
         acGPeQlvCfeSBv/aRdEYQ/ABuPJ5OBd4SNGyz+fiwirgmOCn1ZvOpCjzGGuyhpTViaXm
         0+cw==
X-Gm-Message-State: AHQUAuYXK+7nHWzqtOckTfflBkD1lBIBc5aIGZxjYYVB3eqR8Ld7EONp
        +2EvgLrInO7Eo0km3MGg3xZX4gwd5pq4i5EmHD8Ubg==
X-Google-Smtp-Source: AHgI3IZS4OPCJFgrI6TGvQta2hyeeBwcQsKwiKvd0l3zmi+l9ztq4HCVSkBsZIevfqe2AiRxcti/0o3YeV4Qv4Bvr54=
X-Received: by 2002:ac8:25d9:: with SMTP id f25mr7225238qtf.156.1549863105900;
 Sun, 10 Feb 2019 21:31:45 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org> <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
In-Reply-To: <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
From:   ronnie sahlberg <ronniesahlberg@gmail.com>
Date:   Mon, 11 Feb 2019 15:31:34 +1000
Message-ID: <CAN05THTfHsMT3g+L=c+FAJQJB6A_6bszyf5=firQn1M_12K3TQ@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker Lendecke <Volker.Lendecke@sernet.de>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Feb 9, 2019 at 12:47 AM Amir Goldstein via samba-technical
<samba-technical@lists.samba.org> wrote:
>
> On Fri, Feb 8, 2019 at 3:10 PM Jeff Layton <jlayton@kernel.org> wrote:
> >
> > On Fri, 2019-02-08 at 13:20 +0200, Amir Goldstein wrote:
> > > Hi Bruce,
> > >
> > > I have been following you discussion with Volker Lendecke
> > > on the samba technical mailing list [1] and have had discussed
> > > this issue with Volker myself as well.
> > >
> > > I decided to start this new thread to bring some kernel developers
> > > in the loop and to propose an idea that takes a somewhat
> > > different approach to the "interop" approaches I have seen
> > > so far. "interop" in this context often means consistency of file
> > > lock states between samba and nfs server, but I am referring
> > > to the stronger sense of interop with local filesystem on the server.
> > >
> > > You pointed to Pavel Shilovsky's O_DENY* patches [2] as a possible
> > > solution to interop of NFS Share Reservation and SMB Share Mode
> > > with local filesystems.
> > > Some of the complaints on this approach were (rightfully) concerned
> > > about DoS and the prospect of plaguing Linux with Windows server
> > > "files left open" issues.
> > >
> > > My idea comes from the observation that Windows server
> > > administrators can release locked files that were left open by clients.
> > > I suppose that an NFS server admin can do the same?
> >
> > The Linux kernel has no mechanism for this (aside from sending a SIGKILL
> > to lockd, which makes it drop all locks). Solaris did have a tool for
> > this at one point (and probably still does).
> >
> > It's a little less of a problem now than it used to be with NFS, given
> > the move to NFSv4 (which has lease-based locking). If you have
> > misbehaving clients, you just kick them out and their locks eventually
> > go away. v3 locks can stick around in perpetuity however, so people have
> > long wanted such a tool on Linux as well.
> >

Now, maybe NFSv3 is rapidly becoming obsolete so it might not be worth
spending time on.
We has such tools at EMC for our servers, NetApp had too. Customers
loved these tools especially since
locking and nfsv3 was always very fragile :-)

Many years ago I looked at linux nfs in order to see if I could write
such tools.
(the tools themselves are really simple  they just uses the NLM
protocol which the kernel already speaks so no need to add any new
apis.)
Takling from dim memory, but I think what tripped me up is that for
NLM_TEST reply, linux does not fill in the OH field, i.e. the owner
string,
which you would need to send a spoofed NLM_UNLOCK to release the lock.


>
> In a nut shell, I think my proposal is that samba will do something
> similar and request leases from the kernel instead of trying to
> enforce real mandatory locks.
>
> > > That realization makes "share access" locks (a.k.a. MAND_LOCK)
> > > not so very different from oplocks (leases/delegations).
> > > As long as samba and nfsd cooperate nicely with MAND_LOCK
> > > semantics, we don't really have to force local filesystems
> > > to obay MAND_LOCK semantics. If the file servers take leases
> > > on local filesystems, they will not get exclusive write access for
> > > files already open for write on local filesytem and same for read.
> > >
> >
> > I think this last statement isn't correct (if I'm parsing it correctly).
> > If a file is already open for write, then you just don't get a lease
> > when you try to request one. Ditto for write leases if it's already open
> > for read.
> >
>
> I think you miss read what I miss wrote ;-)
> As the title of this thread states, I am talking about the first case
> of acquiring an exclusive or read shared access to file at open time.
> It may be the fact that samba currently calls flock(LOCK_MAND)
> that is the source for confusion.
>
> Open failure is the expected behavior if file is already open for
> write (or read) on local filesystem, so my suggestion is:
> - Server opens the file and request a lease based of desired share mode
> - If file server got the lease, client gets the file handle
> - Otherwise, client gets an open failure
>
> > > On local file access on the server that violates the share mode,
> > > the file server acts as a grumpy washed out administrator that
> > > automatically grants any lock revoke ticket after timeout.
> > >
> >
> > Devil's advocate:
> >
> > Is this situation any better than just teaching the NFS/SMB servers to
> > track these locks out of band? Both samba and most NFS servers respect
> > share/deny mode locks, but only internally -- they aren't aware of the
> > others'. We could (in principle) come up with a mechanism to track these
> > that doesn't involve plumbing them into the kernel.
> >
>
> That would be a prerequisite to my suggested solution, as I wrote:
> "As long as samba and nfsd cooperate nicely with LOCK_MAND..."
> That means the two file servers cooperate on the share mode locks
> and try to figure out if there are outstanding leases before opening
> a file that will break those leases.
>
> > That said, coherent locking is best done in the kernel, IMO...
> >
>
> Indeed...
>
> > > This model may not fit use cases where "real" interop with
> > > local filesystem is needed, but compared to the existing
> > > solution (no interop at all) it is quite an improvement.
> > >
> > > Furthermore, short of SMB DENY_DELETE, we may not even
> > > need to change any kernel APIs.
> > > The addition of O_DENY* open flags can make programming
> > > easier, but taking a lease on an open file is still safe enough
> > > to implement share reservation (no?).
> > >
> > > Satisfying DENY_DELETE could be more tricky, but perhaps
> > > the existing SILLYRENAME interface of==between knfsd and vfs
> > > could be somehow utilized for this purpose?
> > >
> > > I though of bringing this up as a TOPIC for LSF/MM, but wanted
> > > to consult with you first. I am sure that you or Jeff can do a better
> > > job than me in enumerating the "interop" file lock issues that
> > > could be discussed in filesystems track forum.
> > >
> > > Thoughts? Explanation why this idea is idiotic?
> >
> > I think it's not a single idea. There are really two different aspects
> > to this given that we're really talking about two different types of
> > locks in SMB. I think you have to consider solving these problems
> > separately:
> >
> > 1) the ability to set a (typically whole-file) share/deny lock
> > atomically when you open a file. This is necessary for coherent
> > share/deny lock semantics. Note that these are only enforced open()
> > time.
> >
> > 2) mandatory locking (forbidding reads and writes on a byte range when
> > there is a conflicting lock set).
> >
>
> I was only trying to address the first problem (small steps...).
>
> > The first could (probably) be solved with something like what Pavel
> > proposed a few years ago...or maybe we just wire up O_EXLOCK and
> > O_SHLOCK:
> >
> >     https://www.gnu.org/software/libc/manual/html_node/Open_002dtime-Flags.html
> >
>
> Nice. I wasn't aware of those BSD flags.
>
> > This seems like a fine idea (in principle) but it needs someone to drive
> > the work forward. You'll also likely be consuming a couple of O_* flags,
> > which could be tough sell (unless you come up with another way to do
> > it).
> >
>
> Once I know the obstacles to watch out from, I can drive this work.
> Thing is, I am not convinced myself that any new O_ flags are needed.
>
> How about this (for samba, knfsd is simpler):
> - pfd = open(filename, O_PATH)
> - flock(pfd, LOCK_MAND) (for file servers interop)
> - vfs checks no conflicting LOCK_MAND locks (like patch you once posted)
> - open(filename, O_RDWR) (and verify st_ino like samba does)
> - Request lease (for local fs interop)
> - check_conflicting_open() is changed to use inode_is_open_for_read()
>   instead of checking d_count and i_count.
> - we already have i_readcount, just need to remove ifdef CONFIG_IMA
> - On lease break (from local fs), break client oplocks and invalidate
> file handle on server
>
> Thanks,
> Amir.
>
