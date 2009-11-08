From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] proc: revalidate dentry returned by proc_pid_follow_link
Date: Sun, 08 Nov 2009 02:15:57 -0800
Message-ID: <m17hu1miea.fsf@fess.ebiederm.org>
References: <1257513594-31071-1-git-send-email-jlayton@redhat.com>
	<20091106203601.GD27751@shareable.org>
	<20091106160612.4cd05e76@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753226AbZKHKQB@vger.kernel.org>
In-Reply-To: <20091106160612.4cd05e76@tlielax.poochiereds.net> (Jeff Layton's message of "Fri\, 6 Nov 2009 16\:06\:12 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

> On Fri, 6 Nov 2009 20:36:01 +0000
> Jamie Lokier <jamie@shareable.org> wrote:
>
>> Jeff Layton wrote:
>> > The problem here is that this makes that code shortcut any lookup or
>> > revalidation of the dentry. In general, this isn't a problem -- in most
>> > cases the dentry is known to be good. It is a problem however for NFSv4.
>> > If this symlink is followed on an open operation no actual open call
>> > occurs and the open state isn't properly established. This causes
>> > problems when we later try to use this file descriptor for actual
>> > operations.
>> 
>> As NFS uses open() as a kind of fcntl-lock barrier, I can see it's
>> important to do _something_ on new opens, rather than just cloning
>> most of the file descriptor.
>> 
>
> I guess you mean the close-to-open cache consistency? If so, this
> problem doesn't actually break that. The actual nfs_file_open call does
> occur even when you're opening by following one of these symlinks. I
> believe the cache consistency code occurs there.
>
> The problem here is really nfsv4 specific. There the on-the-wire open
> call and initialization of state actually happens during d_lookup and
> d_revalidate. Neither of these happens with these LAST_BIND symlinks so
> we end up with a filp that has no NFSv4 state attached.
>
>> > This patch takes a minimalist approach to fixing this by making the
>> > /proc/pid follow_link routine revalidate the dentry before returning it.
>> 
>> What happens if the file descriptor you are re-opening is for a file
>> which has been deleted.  Does it still have a revalidatable dentry?
>> 
>
> Well, these LAST_BIND symlinks return a real dget'ed dentry today. If
> we assume that it always returns a valid dentry (which seems to be the
> case), then I suppose it's OK to do a d_revalidate against it.
>
> It's possible though that that revalidate will either fail though or
> return that it's no good. In that case, this code just returns ESTALE
> which should make the path walking code revalidate all the way up the
> chain. That should (hopefully) make whatever syscall we're servicing
> return an error.

Hmm.  Looking at the code I get the impression that a file bind mount
will have exactly the same problem.

Can you confirm.

If file bind mounts also have this problem a bugfix to to just
proc seems questionable.

Eric
