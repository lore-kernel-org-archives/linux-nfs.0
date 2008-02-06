From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 6 Feb 2008 16:45:08 -0500
Message-ID: <20080206214508.GO5342@fieldses.org>
References: <20080205090132.GA8286@stro.at> <1202248931.12271.18.camel@heimdal.trondhjem.org> <003301c86888$ed735a20$0301a8c0@MURTLE> <1202310021.12647.6.camel@heimdal.trondhjem.org> <20080206150739.GA5342@fieldses.org> <1202310924.12647.24.camel@heimdal.trondhjem.org> <20080206172315.GE5342@fieldses.org> <1202320337.14889.18.camel@heimdal.trondhjem.org> <20080206183128.GG5342@fieldses.org> <37673.203.167.214.129.1202332746.squirrel@mail.orcon.net.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:57768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991AbYBFVpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 16:45:15 -0500
In-Reply-To: <37673.203.167.214.129.1202332746.squirrel-pmwrj2wvkLORZ0GbGNPwb6VXKuFTiq87@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2008 at 10:19:06AM +1300, Andrew Dixie wrote:
> 
> > Oh, right, I was confusing client and server reboot and assuming the
> > client would forget the uniquifier on server reboot.  That's obviously
> > wrong!  The client will forget its own uniquifier on client reboot, but
> > that's alright since it's happy enough just to let that old state time
> > out at that point.  So the only possible problem is suboptimal behavior
> > when the client reboot time is less than the lease time.
> 
> There is one client, a stable connection between client and server, and
> neither client or server are being rebooted.
> Are the "string in use by client" messages still expected?

Assuming the client creates and destroys clientid's on demand, as
they're needed for opens, and uses whatever user credential it has at
hand to do so, then I think a sequence of alternating opens and closes
as different users could produce this.

But no, it doesn't indicate any real problem on its own.

> Below is a program that attempts to open a file that is contained in a
> directory that has been deleted by another client.
> 
> I'm not sure these are conditions that are normally occuring, it's just
> something I encountered trying to reproduce the hang.
> 
> This reliably reproduces:
> Feb  7 09:55:01 devfile kernel: NFSD: preprocess_seqid_op: bad seqid
> (expected 20, got 22)

That's a bug though, either on the client or server side.

--b.

> 
> And about 1 in 10 times it also reproduces:
> Feb  7 09:55:01 devfile kernel: NFSD: setclientid: string in use by
> client(clientid 47a627bd/0000044b)
> 
> The server is 2.6.18-5 from debian.
> 
> ---
> 
> #include <string.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <errno.h>
> #include <fcntl.h>
> #include <sys/stat.h>
> #include <stdlib.h>
> 
> #define ASSERT(x) \
>         if (!(x)) { fprintf(stderr, "%s:%i:assert:" #x "\n", __FILE__,
> __LINE__); abort(); }
> 
> #define testdir "/home/andrewd/testdir"
> #define testfile testdir "/fred"
> 
> int main(int argc, char *argv[])
> {
>         int fd;
>         int rv;
> 
>         rv = mkdir(testdir,0777);
>         ASSERT(rv == 0 || errno == EEXIST);
> 
>         fd = open(testfile, O_CREAT|O_WRONLY);
>         ASSERT(fd != -1);
>         rv = write(fd, "stuff\n", 6);
>         ASSERT(rv == 6);
>         close(fd);
> 
>         rv = access(testfile, 0);
>         ASSERT(rv == 0);
> 
>         // Remove directory via another client (nfsv3)
>         system("ssh devlin7 rm -r "testdir);
> 
>         // Try to open file
>         fd = open(testfile, O_RDONLY);
>         printf("got fd:%i errno:%i\n", fd, errno);
>         // fd == -1, errno = ENOENT
>         // This is expected, error on nfs server is not.
>         return 0;
> }
> 
> 
