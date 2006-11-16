From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!
Date: Thu, 16 Nov 2006 15:55:54 -0500
Message-ID: <1163710555.5895.8.camel@lade.trondhjem.org>
References: <20061116205010.69453.qmail@web58112.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061116205010.69453.qmail@web58112.mail.re3.yahoo.com>
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
