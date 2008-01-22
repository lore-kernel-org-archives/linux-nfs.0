From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 11:06:34 -0500 (EST)
Message-ID: <200801221606.LAA15590@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: bhalevy@panasas.com
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

> > They should really be converted into inlined functions.
> > 
> > Cheers
> >   Trond
> 
> Agreed.  How about the following:

Ok, you've tickled my curiosity...why? Unless a macro is large and is
used many times (my really old nfs code was like that, being written
for a compiler that didn't support inline functions), what is the
advantage of inline functions? Or is it just that the code is more readable?

Just curious, I don't have any problem with using inline functions, rick
