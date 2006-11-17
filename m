From: Open Source <opensource3141@yahoo.com>
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!
Date: Fri, 17 Nov 2006 11:59:25 -0800 (PST)
Message-ID: <20061117195925.71840.qmail@web58101.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Thanks Trond.  Saving the patch did the trick.  I had
to do some manual hacking to get the patch to
apply because you must have done your diff
against a different kernel tree revision.  I'm using
2.6.18 from FC5 updates.

Once I massaged things, the patch compiled and it
works.  I am able to mount more than one partition
with no problems now.  However, I cannot speak
to the finer points (like memory leaks, etc.) since
I don't know the code so well.  I trust someone else
will independently verify it (i.e., code review) before
it gets into the kernel tree.

So this brings me back to the question?  Can we get
this is back into the main tree as soon as possible?
2.6.19 is on rc5.  So ideally we could get it in there
soon.  2.6.18 has a .2 subsubrelease.  So we could
also get it into the .3 version soon.  Thoughts?

Thanks again,
Paarvai


----- Original Message ----
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Open Source <opensource3141@yahoo.com>
Cc: nfsv4@linux-nfs.org; nfs@lists.sourceforge.net
Sent: Thursday, November 16, 2006 12:55:54 PM
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!

On Thu, 2006-11-16 at 12:50 -0800, Open Source wrote:
> I know this might be a dumb question but I'm
> not able to apply the patch.  How do I do this?
> 
> I cut and paste everything from the "diff --git"
> line into a file.
> 
> Then I did: "patch -p1 < nfs_pipe_fix.patch"
> while sitting in the root directory of my kernel source.
> 
> I get the following error:
> 
> patching file include/linux/sunrpc/clnt.h
> patch: **** malformed patch at line 11: };

Don't cut n' paste, since that tends to mangle spaces, linefeed, etc.
Just save the entire message using your mail browser's 'save to file'
feature and feed the resulting file to 'patch -p1'.

Cheers,
 Trond
