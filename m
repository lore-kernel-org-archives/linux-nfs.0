Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755467Ab3CESNL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 13:13:11 -0500
Date: Tue, 5 Mar 2013 13:13:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo <simo@samba.org>
Cc: Andy Lutomirski <luto@amacapital.net>,
        Pavel Shilovsky <piastry@etersoft.ru>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: Re: [PATCH v3 0/7] Add O_DENY* support for VFS and CIFS/NFS
Message-ID: <20130305181306.GA15816@fieldses.org>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
 <512FD1D5.3010106@mit.edu>
 <20130304211923.GI20389@fieldses.org>
 <5135250A.30604@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5135250A.30604@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 04, 2013 at 05:49:46PM -0500, Simo wrote:
> On 03/04/2013 04:19 PM, J. Bruce Fields wrote:
> >On Thu, Feb 28, 2013 at 01:53:25PM -0800, Andy Lutomirski wrote:
> >>[possible resend -- sorry]
> >>
> >>On 02/28/2013 07:25 AM, Pavel Shilovsky wrote:
> >>>This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
> >>>
> >>>These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.
> >>>
> >>>According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why one extra flag O_DENYMAND is added. It indicates to underlying layer that an application want to use O_DENY* flags semantic. It allows us not affect native Linux applications (that don't use O_DENYMAND flag) - so, these flags (and the semantic of open syscall that they bring) are used only for those applications that really want it proccessed that way.
> >>>
> >>>So, we have four new flags:
> >>>O_DENYREAD - to prevent other opens with read access,
> >>>O_DENYWRITE - to prevent other opens with write access,
> >>>O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
> >>>O_DENYMAND - to switch on/off three flags above.
> >>O_DENYMAND doesn't deny anything.  Would a name like O_RESPECT_DENY be
> >>better?
> >>
> >>Other than that, this seems like a sensible mechanism.
> >I'm a little more worried: these are mandatory locks, and applications
> >that use them are used to the locks being enforced correctly.  Are we
> >sure that an application that opens a file O_DENYWRITE won't crash if it
> >sees the file data change while it holds the open?
> 
> The redirector may simply assume it has full control of that part of
> the file and not read nor send data until the lock is released too,
> so you get conflicting views of the file contents between different
> clients if you let a mandatory lock not be mandatory.
> 
> >In general the idea of making a mandatory lock opt-in makes me nervous.
> >I'd prefer something like a mount option, so that we know that everyone
> >on that one filesystem is playing by the same rules, but we can still
> >mount filesystems like / without the option.
> 
> +1
> 
> >But I'll admit I'm definitely not an expert on Windows locking and may
> >be missing something about how these locks are meant to work.
> 
> Mandatory locks really are mandatory in Windows.
> That may not be nice to a Unix system but what can you do ?

I wonder if we could repurpose the existing -omand mount option?

That would be a problem for anyone that wants to allow mandatory fcntl
locks without allowing share locks.  I doubt anyone sane actually uses
mandatory fcntl locks, but still I suppose it would probably be better
to play it safe and use a new mount option.

--b.
