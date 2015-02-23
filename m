Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:50684 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbbBWNzh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 08:55:37 -0500
Received: by mail-vc0-f182.google.com with SMTP id id10so7399079vcb.13
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 05:55:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150223154900.75f62422@notabene.brown>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
	<20150216155429.46cfbab7@notabene.brown>
	<1424643211.4278.10.camel@primarydata.com>
	<20150223094747.040ce304@notabene.brown>
	<CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
	<20150223140526.3328468e@notabene.brown>
	<CAHQdGtTihwVemYehOs3mSKAw+o7NTVPy2hJi67Q=HDS34iQWfw@mail.gmail.com>
	<20150223154900.75f62422@notabene.brown>
Date: Mon, 23 Feb 2015 08:55:36 -0500
Message-ID: <CAHQdGtS79FU3oFF7w3QnuQQS7XhA6NE=inuFvmyKr01GRp6s8Q@mail.gmail.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 22, 2015 at 11:49 PM, NeilBrown <neilb@suse.de> wrote:
> On Sun, 22 Feb 2015 22:33:28 -0500 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>
>> > According to rfc1813, READDIRPLUS returns the filehandles in a "post_of_fh3"
>> > structure which can optionally contain a filehandle.
>> > The text says:
>> >    One of the principles of this revision of the NFS protocol is to
>> >    return the real value from the indicated operation and not an
>> >    error from an incidental operation. The post_op_fh3 structure
>> >    was designed to allow the server to recover from errors
>> >    encountered while constructing a file handle.
>> >
>> > which suggests that the absence of a filehandle could possibly be interpreted
>> > as an error having occurred, but it doesn't allow the client to guess
>> > what that error might have been.
>> > It certainly doesn't allow the client to deduce "you're not supposed to ever
>> > see this inode".
>>
>> NFSv3 had no concept of submounts so, quite frankly, it should not be
>> considered authoritative in this case.
>
> The presence or otherwise of submounts is tangential to the bug.
> The spec implies that nothing can be deduced from the absence of a filehandle
> in a READDIRPLUS reply, but the code appears to deduce something.  This is a
> bug.  submounts happen to trigger it in the one case we have clear evidence
> for.
>
>
>>
>> >> IOW: it is literally the case that the client is supposed to create a
>> >> proxy inode because this is supposed to be a mountpoint.
>> >
>> > This may be valid in the specific case that we are talking to a Linux NFSv3
>> > server (of a certain vintage).  It isn't generally valid.
>> >
>> >
>> >>
>> >> > I certainly agree that there may be other issues with this code.  It is
>> >> > unlikely to handle volatile filehandles well, and as you say, referrals may
>> >> > well be an issue too.
>> >> >
>> >> > But surely if the server didn't return a valid filehandle, then it is wrong
>> >> > to pretend that "all-zeros" is a valid filehandle.  That is what the current
>> >> > code does.
>> >>
>> >> As long as we have a valid mounted-on-fileid or a valid fileid, then
>> >> we can still discriminate. That is also what the current code does.
>> >> The only really broken case is if the server returns no filehandle or
>> >> fileid. AFAICS we should be handling that case correctly too in
>> >> nfs_refresh_inode().
>> >
>> > When nfs_same_file() returns 'true', I agree that nfs_refresh_inode() does
>> > the correct thing.
>> > When nfs_same_file() returns 'false', (e.g. the server returns no
>> > filehandle), then we don't even get to nfs_refresh_inode().
>> >
>> > When readdirplus returns the expected filehandle and/or  fileid, we should
>> > clearly refresh the cached attributed.  When it returns clearly different
>> > information it is reasonable to discard the cached information.
>> > When it explicitly returns no information - there is nothing that can be
>> > assumed.
>>
>> Your statement assumes that fh->size == 0 implies the server returned
>> no information. I strongly disagree.
>
> I accept that a server might genuinely return a filehandle with a size of
> zero for some one object (maybe a root directory or something).
> In that case, this code:
>
>                 if (*p != xdr_zero) {
>                         error = decode_nfs_fh3(xdr, entry->fh);
>                         if (unlikely(error)) {
>                                 if (error == -E2BIG)
>                                         goto out_truncated;
>                                 return error;
>                         }
>                 } else
>                         zero_nfs_fh3(entry->fh);
>
> in nfs3_decode_dirent is wrong.
> 'zero_nfs_fh3' should not be used as that makes the non-existent filehandle
> look like something that could be a genuine filehandle.
> Rather something like
>    entry->fh->size == NFS_NO_FH_SIZE;
> should be used, where NFS_NO_FH_SIZE is (NFS_MAXFHSIZE+1) or similar.
>
> Or maybe entry->fh should  be set to NULL if no filehandle is present.
>
>
>> No information => fh->size == 0, but the reverse is not the case, as
>> you indeed admit in your changelog.
>
> I didn't not mean to admit that.  I admitted that the server could genuinely
> return a filehandle that was different to the one cached by the client.  I did
> not mean that the server could genuinely return a filehandle with size of 0
> (though I now agree that is possible as the spec doesn't forbid it).
>
> On glancing through RFC1813 I noticed:
>
>    Clients should use file handle
>    comparisons only to improve performance, not for correct
>    behavior.
>
> This suggests that triggering an unmount when filehandles don't match is not
> correct.  Flushing the cache is OK (that is a performance issue).  Removing
> mountpoints is not.  So the change to d_invalidate() in 3.18 really isn't
> very good for NFS.
>

It really doesn't matter what the NFSv3 spec says here. We store the
filehandle in the inode, and if that filehandle changes then we drop
the inode (and hence the dentry). This has always been the case and is
not particular to the readdir code. We do the exact same thing in
nfs_lookup_revalidate().
The reason why we ignore the letter of the NFSv3 spec here is reality:
NetApp chose to ignore the spec admonition about keeping fileids
unique for the case where they create a snapshot. That basically means
the filehandle is the only thing we can rely on to know when a file is
the same and can be gathered into the same inode.

The NFSv4 spec, which adds protocol support for crossing submounts on
the server tried to clarify things in the section entitled "Data
Caching and File Identity", and we do try to stick to that
clarification: the check for mountpoints is equivalent here to the
fsid check.

>>
>> That said, we're talking about the Linux knfsd server here, which
>> _always_ returns a filehandle unless there request races with an
>> unlink or the entry is a mountpoint.
>
> Surely the implementation should, where possible, be written to the spec, not
> to some particular server implementation.

It is. The question is where the regression comes from.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
